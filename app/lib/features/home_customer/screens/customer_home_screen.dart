import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../auth/controller/auth_controller.dart';
import '../../mode/widgets/mode_toggle.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    return Scaffold(
      backgroundColor: LokalColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LokalSpacing.lg,
                  LokalSpacing.md,
                  LokalSpacing.lg,
                  LokalSpacing.md,
                ),
                child: Row(
                  children: [
                    const _Avatar(),
                    const SizedBox(width: LokalSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: LokalColors.onSurfaceVariant, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Chennai, T. Nagar',
                                style: LokalTypography.labelMd.copyWith(
                                  color: LokalColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.fullName.split(' ').first ?? 'Welcome',
                            style: LokalTypography.headlineSm,
                          ),
                        ],
                      ),
                    ),
                    const ModeToggle(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  LokalSpacing.lg,
                  LokalSpacing.md,
                  LokalSpacing.lg,
                  LokalSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LOKAL', style: LokalTypography.displayMd),
                    const SizedBox(height: LokalSpacing.xs),
                    Text(
                      'Helping hands, just around the corner.',
                      style: LokalTypography.bodyLg.copyWith(
                        color: LokalColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: LokalSpacing.lg),
                    const _SearchField(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: LokalSpacing.md,
                  crossAxisSpacing: LokalSpacing.md,
                  childAspectRatio: 0.88,
                ),
                delegate: SliverChildListDelegate([
                  const _ServiceTile(
                    title: 'Instant Ride\nShare',
                    subtitle: 'Nearby commutes',
                    icon: Icons.electric_scooter_rounded,
                    iconBg: Color(0xFFEAF2FF),
                  ),
                  const _ServiceTile(
                    title: 'Express\nGrocery',
                    subtitle: 'Under 30 min',
                    icon: Icons.shopping_basket_rounded,
                    iconBg: Color(0xFFFFF1E6),
                    badge: 'MOST ORDERED',
                  ),
                  _PhotoTile(
                    imageUrl:
                        'https://images.unsplash.com/photo-1529333166437-7750a6dd5a70?w=640',
                    title: 'Walk & Talk',
                    subtitle: 'Friendly company',
                  ),
                  const _ServiceTile(
                    title: 'Expert\nServices',
                    subtitle: 'Web, Dev & Design',
                    icon: Icons.code_rounded,
                    iconBg: Color(0xFFE6EEFF),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(LokalSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: LokalSpacing.lg, vertical: LokalSpacing.md + 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [LokalColors.primary, LokalColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(LokalRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: LokalColors.primary.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Post a gig',
                          style: LokalTypography.headlineSm
                              .copyWith(color: Colors.white),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(LokalRadius.pill),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    LokalSpacing.lg, 0, LokalSpacing.lg, LokalSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Featured Local Shops',
                        style: LokalTypography.headlineSm),
                    Text('SEE ALL',
                        style: LokalTypography.labelMd
                            .copyWith(color: LokalColors.primary)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
                  itemCount: _featured.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: LokalSpacing.md),
                  itemBuilder: (_, i) => _FeaturedShop(shop: _featured[i]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: LokalSpacing.xxl)),
          ],
        ),
      ),
      bottomNavigationBar: const _HomeBottomBar(),
    );
  }
}

// ───────────────────────────── helpers ────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar();
  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LokalColors.primary, LokalColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(LokalRadius.pill),
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white),
      );
}

class _SearchField extends StatelessWidget {
  const _SearchField();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
      height: 56,
      decoration: BoxDecoration(
        color: LokalColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LokalRadius.pill),
        boxShadow: [
          BoxShadow(
            color: LokalColors.ambientShadow,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              color: LokalColors.onSurfaceVariant, size: 22),
          const SizedBox(width: LokalSpacing.sm + 4),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'What can your community help you with?',
                hintStyle: LokalTypography.bodyMd
                    .copyWith(color: LokalColors.onSurfaceVariant),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    this.badge,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LokalSpacing.md + 2),
      decoration: BoxDecoration(
        color: LokalColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LokalRadius.xl),
        boxShadow: [
          BoxShadow(
            color: LokalColors.ambientShadow,
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(LokalRadius.md),
                ),
                child: Icon(icon, color: LokalColors.primary, size: 24),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: LokalColors.tertiary,
                    borderRadius: BorderRadius.circular(LokalRadius.pill),
                  ),
                  child: Text(
                    badge!,
                    style: LokalTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: LokalTypography.headlineSm.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Text(subtitle, style: LokalTypography.bodySm),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
  final String imageUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(LokalRadius.xl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: LokalColors.surfaceContainerHigh,
            ),
            errorWidget: (_, __, ___) => Container(
              color: LokalColors.surfaceContainerHigh,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.4, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LokalSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(title,
                    style: LokalTypography.headlineSm
                        .copyWith(color: Colors.white, fontSize: 16)),
                Text(subtitle,
                    style: LokalTypography.bodySm.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedShop extends StatelessWidget {
  const _FeaturedShop({required this.shop});
  final Map<String, String> shop;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(LokalSpacing.sm + 2),
      decoration: BoxDecoration(
        color: LokalColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LokalRadius.lg),
        boxShadow: [
          BoxShadow(
            color: LokalColors.ambientShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(LokalRadius.md),
            child: CachedNetworkImage(
              imageUrl: shop['image']!,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 64,
                height: 64,
                color: LokalColors.surfaceContainerHigh,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: LokalColors.surfaceContainerHigh,
              ),
            ),
          ),
          const SizedBox(width: LokalSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(shop['name']!,
                    style: LokalTypography.titleMd.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(shop['tag']!,
                    style: LokalTypography.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          LokalSpacing.lg, LokalSpacing.sm, LokalSpacing.lg, LokalSpacing.md),
      decoration: BoxDecoration(
        color: LokalColors.surface,
        boxShadow: [
          BoxShadow(
            color: LokalColors.ambientShadow,
            blurRadius: 22,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _NavItem(icon: Icons.home_rounded, label: 'Home', active: true),
          _NavItem(icon: Icons.bookmark_outline_rounded, label: 'My Gigs'),
          _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chats'),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.active = false});
  final IconData icon;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final color = active ? LokalColors.primary : LokalColors.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(label,
            style: LokalTypography.caption.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            )),
      ],
    );
  }
}

const _featured = [
  {
    'name': 'Green Bakery',
    'tag': 'Fresh bread • 1.2 km',
    'image':
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
  },
  {
    'name': 'Chai Corner',
    'tag': 'Tea & snacks • 0.4 km',
    'image':
        'https://images.unsplash.com/photo-1567860100080-baa55c3f23d4?w=400',
  },
  {
    'name': 'Fix-It Hub',
    'tag': 'Electronics • 1.8 km',
    'image':
        'https://images.unsplash.com/photo-1581092580497-e0d23cbdf1dc?w=400',
  },
];
