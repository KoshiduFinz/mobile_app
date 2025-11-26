import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_request.dart';
import 'supabase_client.dart';
import 'auth_service.dart';
import 'profile_service.dart';

class RequestService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  // Get sent requests (profile access requests sent by current user)
  Future<List<ProfileRequest>> getSentRequests() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('profile_access_requests')
          .select()
          .eq('requester_id', userId)
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      final List<ProfileRequest> requests = [];

      for (final data in response) {
        final profileOwnerId = data['profile_owner_id']?.toString();
        if (profileOwnerId == null) continue;

        final profile = await _profileService.getProfileById(profileOwnerId);
        if (profile == null) continue;

        // Map status: 'pending', 'approved', 'denied'
        String status = 'pending';
        if (data['status'] == 'approved') {
          status = 'accepted';
        } else if (data['status'] == 'denied') {
          status = 'rejected';
        } else {
          status = data['status'] ?? 'pending';
        }

        requests.add(ProfileRequest(
          id: data['id']?.toString() ?? '',
          profile: profile,
          sentAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
          status: status,
          isSent: true,
        ));
      }

      return requests;
    } catch (e) {
      print('Error fetching sent requests: $e');
      return [];
    }
  }

  // Get received requests (profile access requests received by current user)
  Future<List<ProfileRequest>> getReceivedRequests() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('profile_access_requests')
          .select()
          .eq('profile_owner_id', userId)
          .order('created_at', ascending: false);

      if (response.isEmpty) return [];

      final List<ProfileRequest> requests = [];

      for (final data in response) {
        final requesterId = data['requester_id']?.toString();
        if (requesterId == null) continue;

        final profile = await _profileService.getProfileById(requesterId);
        if (profile == null) continue;

        // Map status: 'pending', 'approved', 'denied'
        String status = 'pending';
        if (data['status'] == 'approved') {
          status = 'accepted';
        } else if (data['status'] == 'denied') {
          status = 'rejected';
        } else {
          status = data['status'] ?? 'pending';
        }

        requests.add(ProfileRequest(
          id: data['id']?.toString() ?? '',
          profile: profile,
          sentAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
          status: status,
          isSent: false,
        ));
      }

      return requests;
    } catch (e) {
      print('Error fetching received requests: $e');
      return [];
    }
  }

  // Get profile views (from notifications with type 'profile_view')
  Future<List<ProfileView>> getProfileViews() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      // Get profile view notifications
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('type', 'profile_view')
          .order('created_at', ascending: false)
          .limit(50);

      if (response.isEmpty) return [];

      final List<ProfileView> views = [];

      for (final data in response) {
        // Extract viewer profile ID from notification data
        final notificationData = data['data'] as Map<String, dynamic>?;
        final viewerId = notificationData?['viewer_id']?.toString() ?? 
                         notificationData?['profile_id']?.toString();
        
        if (viewerId == null) continue;

        final profile = await _profileService.getProfileById(viewerId);
        if (profile == null) continue;

        views.add(ProfileView(
          id: data['id']?.toString() ?? '',
          profile: profile,
          viewedAt: data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
        ));
      }

      return views;
    } catch (e) {
      print('Error fetching profile views: $e');
      return [];
    }
  }
}
