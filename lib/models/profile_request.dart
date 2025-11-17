import 'user_profile.dart';

class ProfileRequest {
  final String id;
  final UserProfile profile;
  final DateTime sentAt;
  final String status; // 'pending', 'accepted', 'rejected'
  final bool isSent; // true if sent by current user, false if received

  ProfileRequest({
    required this.id,
    required this.profile,
    required this.sentAt,
    this.status = 'pending',
    required this.isSent,
  });
}

class ProfileView {
  final String id;
  final UserProfile profile;
  final DateTime viewedAt;

  ProfileView({
    required this.id,
    required this.profile,
    required this.viewedAt,
  });
}

