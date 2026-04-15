import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api_client.dart';
import '../../../core/models/enums.dart';
import '../../profiles/controller/profiles_controller.dart';

/// Holds in-flight onboarding state: selected categories and the filled
/// form payload for each. Survives back/next navigation between steps.
class OnboardingState {
  OnboardingState({
    Set<ServiceCategory>? selected,
    Map<ServiceCategory, Map<String, dynamic>>? forms,
    this.verification = const {},
    this.submitting = false,
    this.error,
  })  : selected = selected ?? {},
        forms = forms ?? {};

  final Set<ServiceCategory> selected;
  final Map<ServiceCategory, Map<String, dynamic>> forms;
  final Map<String, String> verification;
  final bool submitting;
  final String? error;

  OnboardingState copyWith({
    Set<ServiceCategory>? selected,
    Map<ServiceCategory, Map<String, dynamic>>? forms,
    Map<String, String>? verification,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) =>
      OnboardingState(
        selected: selected ?? this.selected,
        forms: forms ?? this.forms,
        verification: verification ?? this.verification,
        submitting: submitting ?? this.submitting,
        error: clearError ? null : (error ?? this.error),
      );
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => OnboardingState();

  void toggleCategory(ServiceCategory c) {
    final next = Set<ServiceCategory>.from(state.selected);
    if (!next.add(c)) next.remove(c);
    state = state.copyWith(selected: next);
  }

  void saveForm(ServiceCategory c, Map<String, dynamic> values) {
    final forms = Map<ServiceCategory, Map<String, dynamic>>.from(state.forms);
    forms[c] = values;
    state = state.copyWith(forms: forms);
  }

  void saveVerification(Map<String, String> values) {
    state = state.copyWith(verification: {...state.verification, ...values});
  }

  /// Submit: creates one service_profile row per selected category.
  Future<bool> submit() async {
    if (state.selected.isEmpty) return false;
    state = state.copyWith(submitting: true, clearError: true);
    try {
      for (final cat in state.selected) {
        final payload = Map<String, dynamic>.from(state.forms[cat] ?? {});
        payload['category'] = cat.value;
        await ApiClient.instance.createProfile(payload);
      }
      await ref.read(profilesControllerProvider.notifier).refresh();
      state = state.copyWith(submitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = OnboardingState();
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
