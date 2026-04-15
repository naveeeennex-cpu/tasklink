import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/service_profile.dart';
import '../../auth/controller/auth_controller.dart';

/// Caches the current user's service profiles. The mode-toggle reads this
/// to decide whether flipping to PROVIDER should route straight to the
/// Provider Home or into onboarding (when profiles.isEmpty).
class ProfilesController extends AsyncNotifier<List<ServiceProfile>> {
  @override
  Future<List<ServiceProfile>> build() async {
    // Re-run when auth state flips.
    final authed = ref.watch(
      authControllerProvider.select((s) => s.isAuthenticated),
    );
    if (!authed) return const [];
    try {
      final rows = await ApiClient.instance.listProfiles();
      return rows.map(ServiceProfile.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final rows = await ApiClient.instance.listProfiles();
      return rows.map(ServiceProfile.fromJson).toList();
    });
  }

  /// True when switching to Provider should trigger onboarding.
  bool get needsOnboarding {
    final list = state.asData?.value ?? const <ServiceProfile>[];
    return list.isEmpty;
  }

  Future<void> createProfile(ServiceCategory category,
      Map<String, dynamic> details) async {
    await ApiClient.instance.createProfile({
      ...details,
      'category': category.value,
    });
    await refresh();
  }

  Future<void> setActive(ServiceCategory category, bool isActive) async {
    await ApiClient.instance
        .updateProfile(category.value, isActive: isActive);
    await refresh();
  }
}

final profilesControllerProvider = AsyncNotifierProvider<ProfilesController,
    List<ServiceProfile>>(ProfilesController.new);
