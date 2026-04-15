import 'enums.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.activeMode = UserMode.consumer,
    this.kycStatus = VerificationStatus.pending,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final UserMode activeMode;
  final VerificationStatus kycStatus;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: (json['full_name'] ?? '') as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        activeMode: UserMode.fromString(json['active_mode'] as String?),
        kycStatus: VerificationStatus.fromString(json['kyc_status'] as String?),
      );

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserMode? activeMode,
    VerificationStatus? kycStatus,
  }) =>
      UserProfile(
        id: id,
        email: email,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        activeMode: activeMode ?? this.activeMode,
        kycStatus: kycStatus ?? this.kycStatus,
      );
}
