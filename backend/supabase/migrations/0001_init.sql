-- LOKAL — authoritative schema (full rebuild)
-- This migration DROPS all existing public.* tables and recreates the
-- full LOKAL domain. Safe to re-run — drops are guarded by IF EXISTS.
-- Order matters: drop in reverse dependency order.

-- ── Drop everything ─────────────────────────────────────────────────
drop table if exists public.chat_messages      cascade;
drop table if exists public.reviews            cascade;
drop table if exists public.bookings           cascade;
drop table if exists public.provider_locations cascade;
drop table if exists public.saved_addresses    cascade;
drop table if exists public.service_requests   cascade;
drop table if exists public.service_profiles   cascade;
drop table if exists public.users              cascade;
-- Legacy tables that may exist from previous attempts:
drop table if exists public.messages           cascade;
drop table if exists public.bookings           cascade;
drop table if exists public.saved_addresses    cascade;

drop type  if exists request_status      cascade;
drop type  if exists verification_status cascade;
drop type  if exists service_category    cascade;
drop type  if exists user_mode           cascade;
drop type  if exists booking_status      cascade;
drop type  if exists address_label       cascade;

-- ── Extensions ──────────────────────────────────────────────────────
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ── Enums ───────────────────────────────────────────────────────────
create type user_mode as enum ('consumer', 'provider');

create type service_category as enum (
  'ride_delivery', 'techie', 'support_partner', 'non_tech'
);

create type verification_status as enum (
  'pending', 'submitted', 'verified', 'rejected'
);

create type request_status as enum (
  'draft', 'open', 'matched', 'in_progress', 'completed', 'cancelled'
);

create type booking_status as enum (
  'accepted', 'en_route', 'arrived', 'in_progress', 'completed', 'cancelled'
);

create type address_label as enum ('home', 'work', 'other');

-- ───────────────────────────────────────────────────────────────────
-- USERS — mirror of auth.users with business fields
-- ───────────────────────────────────────────────────────────────────
create table public.users (
  id             uuid primary key references auth.users(id) on delete cascade,
  email          text unique not null,
  full_name      text not null,
  phone          text,
  avatar_url     text,
  active_mode    user_mode           not null default 'consumer',
  kyc_status     verification_status not null default 'pending',
  -- Last known location (for hyperlocal discovery & ETAs).
  last_lat       double precision,
  last_lng       double precision,
  last_seen_at   timestamptz,
  rating_avg     numeric(3,2) not null default 0,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index idx_users_active_mode on public.users(active_mode);

-- Auto-insert a public.users row whenever auth.users gets a new row.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.users (id, email, full_name, phone)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name',
             split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'phone'
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ───────────────────────────────────────────────────────────────────
-- SAVED ADDRESSES — consumer favourites (home / work / custom)
-- ───────────────────────────────────────────────────────────────────
create table public.saved_addresses (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users(id) on delete cascade,
  label       address_label not null default 'other',
  display     text not null,                      -- "Home", "Office", …
  address     text not null,                      -- full formatted address
  lat         double precision not null,
  lng         double precision not null,
  created_at  timestamptz not null default now()
);

create index idx_addr_user on public.saved_addresses(user_id);

-- ───────────────────────────────────────────────────────────────────
-- SERVICE PROFILES — one row per (user, category)
-- The polymorphic LOKAL core.
-- ───────────────────────────────────────────────────────────────────
create table public.service_profiles (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null references public.users(id) on delete cascade,
  category            service_category not null,
  details             jsonb not null,
  is_active           boolean not null default false,
  verification_status verification_status not null default 'pending',
  rating_avg          numeric(3,2) not null default 0,
  jobs_completed      int not null default 0,
  service_radius_km   int not null default 8,
  base_lat            double precision,
  base_lng            double precision,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (user_id, category)
);

create index idx_sp_user     on public.service_profiles(user_id);
create index idx_sp_category on public.service_profiles(category);
create index idx_sp_active   on public.service_profiles(is_active) where is_active;

-- ───────────────────────────────────────────────────────────────────
-- PROVIDER LOCATIONS — live pings for routing + dispatch
-- ───────────────────────────────────────────────────────────────────
create table public.provider_locations (
  user_id      uuid primary key references public.users(id) on delete cascade,
  lat          double precision not null,
  lng          double precision not null,
  heading_deg  double precision,
  speed_kmh    double precision,
  updated_at   timestamptz not null default now()
);

create index idx_loc_updated on public.provider_locations(updated_at desc);

-- ───────────────────────────────────────────────────────────────────
-- SERVICE REQUESTS — consumer posts, provider feed sees
-- ───────────────────────────────────────────────────────────────────
create table public.service_requests (
  id              uuid primary key default gen_random_uuid(),
  consumer_id     uuid not null references public.users(id) on delete cascade,
  provider_id     uuid references public.users(id) on delete set null,
  category        service_category not null,
  title           text not null,
  description     text,
  pickup          jsonb,                -- {lat,lng,address}
  drop_off        jsonb,                -- `drop` is a reserved word; rename
  scheduled_for   timestamptz,
  budget_inr      int,
  status          request_status not null default 'open',
  distance_km     numeric(6,2),          -- cached from Maps
  duration_sec    int,                   -- cached from Maps
  route_polyline  text,                  -- encoded polyline, cached
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_req_consumer on public.service_requests(consumer_id);
create index idx_req_provider on public.service_requests(provider_id);
create index idx_req_status   on public.service_requests(status);
create index idx_req_category on public.service_requests(category);

-- ───────────────────────────────────────────────────────────────────
-- BOOKINGS — a matched, accepted request becomes a booking
-- ───────────────────────────────────────────────────────────────────
create table public.bookings (
  id              uuid primary key default gen_random_uuid(),
  request_id      uuid not null references public.service_requests(id) on delete cascade,
  consumer_id     uuid not null references public.users(id) on delete cascade,
  provider_id     uuid not null references public.users(id) on delete cascade,
  status          booking_status not null default 'accepted',
  accepted_at     timestamptz not null default now(),
  started_at      timestamptz,
  completed_at    timestamptz,
  price_inr       int,
  pickup          jsonb,
  drop_off        jsonb,
  distance_km     numeric(6,2),
  duration_sec    int,
  route_polyline  text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_bk_request  on public.bookings(request_id);
create index idx_bk_consumer on public.bookings(consumer_id);
create index idx_bk_provider on public.bookings(provider_id);
create index idx_bk_status   on public.bookings(status);

-- ───────────────────────────────────────────────────────────────────
-- REVIEWS — post-completion, bi-directional
-- ───────────────────────────────────────────────────────────────────
create table public.reviews (
  id           uuid primary key default gen_random_uuid(),
  booking_id   uuid not null references public.bookings(id) on delete cascade,
  author_id    uuid not null references public.users(id) on delete cascade,
  target_id    uuid not null references public.users(id) on delete cascade,
  rating       int not null check (rating between 1 and 5),
  comment      text,
  created_at   timestamptz not null default now(),
  unique (booking_id, author_id)
);

create index idx_rv_target on public.reviews(target_id);

-- ───────────────────────────────────────────────────────────────────
-- CHAT MESSAGES — thread per booking
-- ───────────────────────────────────────────────────────────────────
create table public.chat_messages (
  id          uuid primary key default gen_random_uuid(),
  booking_id  uuid not null references public.bookings(id) on delete cascade,
  sender_id   uuid not null references public.users(id) on delete cascade,
  body        text not null,
  created_at  timestamptz not null default now()
);

create index idx_msg_booking on public.chat_messages(booking_id, created_at);

-- ───────────────────────────────────────────────────────────────────
-- updated_at triggers
-- ───────────────────────────────────────────────────────────────────
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

create trigger users_touch       before update on public.users
  for each row execute procedure public.touch_updated_at();
create trigger sp_touch          before update on public.service_profiles
  for each row execute procedure public.touch_updated_at();
create trigger req_touch         before update on public.service_requests
  for each row execute procedure public.touch_updated_at();
create trigger bk_touch          before update on public.bookings
  for each row execute procedure public.touch_updated_at();

-- ───────────────────────────────────────────────────────────────────
-- Row-Level Security
-- ───────────────────────────────────────────────────────────────────
alter table public.users               enable row level security;
alter table public.saved_addresses     enable row level security;
alter table public.service_profiles    enable row level security;
alter table public.provider_locations  enable row level security;
alter table public.service_requests    enable row level security;
alter table public.bookings            enable row level security;
alter table public.reviews             enable row level security;
alter table public.chat_messages       enable row level security;

-- users
create policy users_select_own on public.users
  for select using (auth.uid() = id);
create policy users_update_own on public.users
  for update using (auth.uid() = id);

-- saved_addresses — private
create policy addr_all_own on public.saved_addresses
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- service_profiles — owners write, any authenticated user reads
create policy sp_select_all_auth on public.service_profiles
  for select to authenticated using (true);
create policy sp_write_own on public.service_profiles
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- provider_locations — owner writes, any authenticated reads (for ETA/dispatch)
create policy loc_write_own on public.provider_locations
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
create policy loc_read_auth on public.provider_locations
  for select to authenticated using (true);

-- service_requests — consumer owns; providers see open rows or their own
create policy req_consumer_rw on public.service_requests
  for all using (auth.uid() = consumer_id)
  with check (auth.uid() = consumer_id);
create policy req_provider_read on public.service_requests
  for select to authenticated
  using (status = 'open' or provider_id = auth.uid());

-- bookings — only the two parties see their booking
create policy bk_parties_rw on public.bookings
  for all using (auth.uid() in (consumer_id, provider_id))
  with check (auth.uid() in (consumer_id, provider_id));

-- reviews — author writes their row; anyone authed can read
create policy rv_read_auth on public.reviews
  for select to authenticated using (true);
create policy rv_author_write on public.reviews
  for all using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

-- chat_messages — booking parties only
create policy msg_parties_rw on public.chat_messages
  for all using (
    exists (
      select 1 from public.bookings b
      where b.id = chat_messages.booking_id
        and auth.uid() in (b.consumer_id, b.provider_id)
    )
  )
  with check (auth.uid() = sender_id);
