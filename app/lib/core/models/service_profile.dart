import 'enums.dart';

/// Thin domain class — the `details` payload is kept as a raw map because
/// it's polymorphic by category and always round-trips through JSON anyway.
class ServiceProfile {
  const ServiceProfile({
    required this.id,
    required this.userId,
    required this.category,
    required this.details,
    this.isActive = false,
    this.verificationStatus = VerificationStatus.pending,
    this.ratingAvg = 0,
    this.jobsCompleted = 0,
  });

  final String id;
  final String userId;
  final ServiceCategory category;
  final Map<String, dynamic> details;
  final bool isActive;
  final VerificationStatus verificationStatus;
  final double ratingAvg;
  final int jobsCompleted;

  factory ServiceProfile.fromJson(Map<String, dynamic> json) => ServiceProfile(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        category: ServiceCategory.fromValue(json['category'] as String?) ??
            ServiceCategory.rideDelivery,
        details: Map<String, dynamic>.from(
            json['details'] as Map? ?? const <String, dynamic>{}),
        isActive: (json['is_active'] ?? false) as bool,
        verificationStatus:
            VerificationStatus.fromString(json['verification_status'] as String?),
        ratingAvg: ((json['rating_avg'] ?? 0) as num).toDouble(),
        jobsCompleted: (json['jobs_completed'] ?? 0) as int,
      );
}
