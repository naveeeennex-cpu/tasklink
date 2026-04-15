import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/api_client.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/route_info.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../auth/controller/auth_controller.dart';
import '../../mode/widgets/mode_toggle.dart';
import '../../profiles/controller/profiles_controller.dart';
import '../widgets/live_map.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  bool _online = true;
  String _filter = 'All';
  List<Map<String, dynamic>> _feed = [];
  bool _loading = false;
  RouteInfo? _liveRoute;

  // Demo coordinates — in production these come from provider's current
  // GPS (origin) and the accepted request's drop-off (destination).
  static const _demoOrigin = LatLng(13.0827, 80.2707); // Chennai Central area
  static const _demoDestination = LatLng(13.0569, 80.2425); // Nungambakkam

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFeed);
  }

  Future<void> _loadFeed() async {
    setState(() => _loading = true);
    try {
      // Prefer the first category the user has a profile for.
      final profiles =
          ref.read(profilesControllerProvider).asData?.value ?? const [];
      final cat = profiles.isNotEmpty
          ? profiles.first.category
          : ServiceCategory.rideDelivery;
      _feed = await ApiClient.instance.providerFeed(cat.value);
    } catch (_) {
      _feed = _mockGigs;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(
      authControllerProvider.select((s) => s.user?.fullName ?? 'Earner'),
    );
    final first = name.split(' ').first;
    return Scaffold(
      backgroundColor: LokalColors.darkSurface,
      body: Stack(
        children: [
          // Real Google Map with the shortest route fetched via the
          // backend /maps/route/shortest proxy (key stays server-side).
          Positioned.fill(
            child: LiveRouteMap(
              origin: _demoOrigin,
              destination: _demoDestination,
              onRouteReady: (r) => setState(() => _liveRoute = r),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    LokalColors.darkSurface.withValues(alpha: 0.2),
                    LokalColors.darkSurface.withValues(alpha: 0.85),
                    LokalColors.darkSurface,
                  ],
                  stops: const [0.0, 0.45, 0.85],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(LokalSpacing.lg,
                      LokalSpacing.sm, LokalSpacing.lg, LokalSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              LokalColors.primary,
                              LokalColors.primaryContainer
                            ],
                          ),
                          borderRadius: BorderRadius.circular(LokalRadius.pill),
                        ),
                        child: const Icon(Icons.work_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: LokalSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(first.toUpperCase(),
                                style: LokalTypography.labelLg.copyWith(
                                  color: LokalColors.onDarkSurface,
                                  fontSize: 13,
                                )),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: LokalColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _online ? 'Online' : 'Offline',
                                  style: LokalTypography.bodyMd.copyWith(
                                    color: LokalColors.onDarkSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _OnlinePill(
                        online: _online,
                        onTap: () => setState(() => _online = !_online),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: LokalSpacing.sm),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
                  child: ModeToggle(dark: true),
                ),
                // Earnings + live route hero
                Padding(
                  padding: const EdgeInsets.fromLTRB(LokalSpacing.lg,
                      LokalSpacing.lg, LokalSpacing.lg, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today’s earnings",
                                style: LokalTypography.bodyMd.copyWith(
                                    color: LokalColors.onDarkSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹1,420',
                                style: LokalTypography.displayMd.copyWith(
                                  color: LokalColors.onDarkSurface,
                                  fontSize: 42,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: LokalSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text('+₹320 today',
                                style: LokalTypography.labelLg.copyWith(
                                  color: LokalColors.success,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ],
                      ),
                      if (_liveRoute != null) ...[
                        const SizedBox(height: LokalSpacing.md),
                        _LiveRouteBadge(route: _liveRoute!),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                // Bottom sheet — available gigs
                Container(
                  decoration: BoxDecoration(
                    color: LokalColors.darkSurfaceContainer,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(LokalRadius.xl)),
                  ),
                  padding: const EdgeInsets.fromLTRB(LokalSpacing.lg,
                      LokalSpacing.md, LokalSpacing.lg, LokalSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: LokalColors.onDarkSurfaceVariant
                                .withValues(alpha: 0.5),
                            borderRadius:
                                BorderRadius.circular(LokalRadius.pill),
                          ),
                        ),
                      ),
                      const SizedBox(height: LokalSpacing.md),
                      Row(
                        children: [
                          Text('Available Gigs',
                              style: LokalTypography.headlineSm
                                  .copyWith(color: LokalColors.onDarkSurface)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: LokalColors.primaryContainer
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                  LokalRadius.pill),
                            ),
                            child: Text(
                              '${_feed.length} NEARBY',
                              style: LokalTypography.caption.copyWith(
                                color: LokalColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: LokalSpacing.md),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final f in const [
                              'All',
                              'Nearby',
                              'High Pay',
                              'Quick'
                            ])
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: LokalSpacing.sm),
                                child: _DarkFilter(
                                  label: f,
                                  selected: _filter == f,
                                  onTap: () => setState(() => _filter = f),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: LokalSpacing.sm),
                      SizedBox(
                        height: 220,
                        child: _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: LokalColors.primaryContainer))
                            : ListView.separated(
                                itemCount: _feed.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: LokalSpacing.sm + 2),
                                itemBuilder: (_, i) => _GigCard(gig: _feed[i]),
                              ),
                      ),
                    ],
                  ),
                ),
                const _ProviderNavBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── sub-widgets ───────────────────────────

class _LiveRouteBadge extends StatelessWidget {
  const _LiveRouteBadge({required this.route});
  final RouteInfo route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: LokalSpacing.md, vertical: LokalSpacing.sm + 2),
      decoration: BoxDecoration(
        color: LokalColors.darkSurfaceContainerHigh.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(LokalRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.alt_route_rounded,
              color: LokalColors.primaryContainer, size: 18),
          const SizedBox(width: 8),
          Text(
            'Shortest route',
            style: LokalTypography.labelLg.copyWith(
              color: LokalColors.onDarkSurfaceVariant,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: LokalColors.onDarkSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${route.distanceText} • ${route.durationText}',
            style: LokalTypography.labelLg.copyWith(
              color: LokalColors.onDarkSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


class _OnlinePill extends StatelessWidget {
  const _OnlinePill({required this.online, required this.onTap});
  final bool online;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: LokalSpacing.md, vertical: LokalSpacing.xs + 2),
        decoration: BoxDecoration(
          color: online ? LokalColors.success : LokalColors.darkSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(LokalRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              online ? 'ONLINE' : 'OFFLINE',
              style: LokalTypography.labelLg.copyWith(
                color: online ? Colors.white : LokalColors.onDarkSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: online ? 1 : 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkFilter extends StatelessWidget {
  const _DarkFilter(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: LokalSpacing.md + 2, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? LokalColors.primaryContainer.withValues(alpha: 0.25)
              : LokalColors.darkSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(LokalRadius.pill),
        ),
        child: Text(
          label,
          style: LokalTypography.labelLg.copyWith(
            color: selected
                ? LokalColors.primaryContainer
                : LokalColors.onDarkSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _GigCard extends StatelessWidget {
  const _GigCard({required this.gig});
  final Map<String, dynamic> gig;

  @override
  Widget build(BuildContext context) {
    final title = (gig['title'] ?? 'Untitled') as String;
    final km = (gig['km'] ?? '1.0 km').toString();
    final mins = (gig['mins'] ?? '15 mins').toString();
    final price = gig['price'] ?? 150;
    final icon = gig['icon'] as IconData? ?? Icons.local_shipping_rounded;

    return Container(
      padding: const EdgeInsets.all(LokalSpacing.md),
      decoration: BoxDecoration(
        color: LokalColors.darkSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(LokalRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: LokalColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(LokalRadius.md),
            ),
            child: Icon(icon, color: LokalColors.primaryContainer),
          ),
          const SizedBox(width: LokalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: LokalTypography.titleMd
                        .copyWith(color: LokalColors.onDarkSurface)),
                const SizedBox(height: 2),
                Text('$km • $mins',
                    style: LokalTypography.bodySm.copyWith(
                        color: LokalColors.onDarkSurfaceVariant)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹$price',
                  style: LokalTypography.headlineSm
                      .copyWith(color: LokalColors.onDarkSurface, fontSize: 18)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: LokalSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      LokalColors.primary,
                      LokalColors.primaryContainer
                    ],
                  ),
                  borderRadius: BorderRadius.circular(LokalRadius.pill),
                ),
                child: Text('ACCEPT',
                    style: LokalTypography.labelLg.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderNavBar extends StatelessWidget {
  const _ProviderNavBar();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          LokalSpacing.lg, LokalSpacing.sm, LokalSpacing.lg, LokalSpacing.md),
      color: LokalColors.darkSurfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _DarkNavItem(
              icon: Icons.home_rounded, label: 'HOME', active: true),
          _DarkNavItem(
              icon: Icons.currency_rupee_rounded, label: 'EARNINGS'),
          _DarkNavItem(icon: Icons.history_rounded, label: 'HISTORY'),
          _DarkNavItem(icon: Icons.person_outline_rounded, label: 'PROFILE'),
        ],
      ),
    );
  }
}

class _DarkNavItem extends StatelessWidget {
  const _DarkNavItem(
      {required this.icon, required this.label, this.active = false});
  final IconData icon;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final c = active
        ? LokalColors.primaryContainer
        : LokalColors.onDarkSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c, size: 22),
        const SizedBox(height: 2),
        Text(label,
            style: LokalTypography.caption.copyWith(
              color: c,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            )),
      ],
    );
  }
}

// ── Mock feed used when backend is unavailable in dev ────────────────
final _mockGigs = <Map<String, dynamic>>[
  {
    'title': 'Grocery Delivery',
    'km': '1.2 km',
    'mins': '15 mins',
    'price': 150,
    'icon': Icons.shopping_basket_rounded,
  },
  {
    'title': 'Quick Ride',
    'km': '0.8 km',
    'mins': '22 mins',
    'price': 210,
    'icon': Icons.electric_scooter_rounded,
  },
  {
    'title': 'AC Service Visit',
    'km': '2.4 km',
    'mins': '40 mins',
    'price': 450,
    'icon': Icons.handyman_rounded,
  },
];
