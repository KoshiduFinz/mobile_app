import 'profile_request.dart';
import 'mock_profiles.dart';

class MockRequests {
  static List<ProfileRequest> getSentRequests() {
    final profiles = MockProfiles.getProfiles();
    return [
      ProfileRequest(
        id: '1',
        profile: profiles[1], // Ravi
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'pending',
        isSent: true,
      ),
      ProfileRequest(
        id: '2',
        profile: profiles[3], // Dilshan
        sentAt: DateTime.now().subtract(const Duration(days: 5)),
        status: 'accepted',
        isSent: true,
      ),
      ProfileRequest(
        id: '3',
        profile: profiles[4], // Nisha
        sentAt: DateTime.now().subtract(const Duration(days: 7)),
        status: 'pending',
        isSent: true,
      ),
    ];
  }

  static List<ProfileRequest> getReceivedRequests() {
    final profiles = MockProfiles.getProfiles();
    return [
      ProfileRequest(
        id: '4',
        profile: profiles[0], // Priya
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'pending',
        isSent: false,
      ),
      ProfileRequest(
        id: '5',
        profile: profiles[2], // Anjali
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
        isSent: false,
      ),
    ];
  }

  static List<ProfileView> getProfileViews() {
    final profiles = MockProfiles.getProfiles();
    return [
      ProfileView(
        id: '1',
        profile: profiles[0], // Priya
        viewedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ProfileView(
        id: '2',
        profile: profiles[1], // Ravi
        viewedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ProfileView(
        id: '3',
        profile: profiles[2], // Anjali
        viewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProfileView(
        id: '4',
        profile: profiles[3], // Dilshan
        viewedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProfileView(
        id: '5',
        profile: profiles[4], // Nisha
        viewedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}

