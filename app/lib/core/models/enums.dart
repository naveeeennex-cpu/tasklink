/// Domain enums — mirrored from backend/app/models/enums.py.
/// Keep these in lock-step with the server.

enum UserMode {
  consumer,
  provider;

  String get value => name;
  static UserMode fromString(String? v) =>
      UserMode.values.firstWhere((m) => m.name == v, orElse: () => UserMode.consumer);
}

enum ServiceCategory {
  rideDelivery('ride_delivery', 'Ride & Delivery'),
  techie('techie', 'Techie'),
  supportPartner('support_partner', 'Support Partner'),
  nonTech('non_tech', 'Non-Tech Services');

  const ServiceCategory(this.value, this.label);
  final String value;
  final String label;

  static ServiceCategory? fromValue(String? v) {
    for (final c in ServiceCategory.values) {
      if (c.value == v) return c;
    }
    return null;
  }
}

enum VerificationStatus {
  pending,
  submitted,
  verified,
  rejected;

  String get value => name;
  static VerificationStatus fromString(String? v) => VerificationStatus.values
      .firstWhere((s) => s.name == v, orElse: () => VerificationStatus.pending);
}

enum RequestStatus {
  draft,
  open,
  matched,
  inProgress('in_progress'),
  completed,
  cancelled;

  const RequestStatus([String? override]) : _override = override;
  final String? _override;
  String get value => _override ?? name;
}
