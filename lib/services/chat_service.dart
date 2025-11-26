import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import 'supabase_client.dart';
import 'auth_service.dart';
import 'profile_service.dart';

class ChatService {
  final SupabaseClient _supabase = SupabaseService.client;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  // Get all conversations for current user
  Future<List<ChatConversation>> getConversations() async {
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) return [];

      // Fetch conversations where current user is either participant_one or participant_two
      final conversationsResponse = await _supabase
          .from('conversations')
          .select()
          .or('participant_one.eq.$userId,participant_two.eq.$userId')
          .order('started_at', ascending: false);

      if (conversationsResponse.isEmpty) {
        return [];
      }

      final List<ChatConversation> conversations = [];

      for (final convData in conversationsResponse) {
        // Determine the other user's ID
        final otherUserId = convData['participant_one'] == userId 
            ? convData['participant_two']?.toString()
            : convData['participant_one']?.toString();

        if (otherUserId == null) continue;

        // Fetch the other user's profile
        final otherUserProfile = await _profileService.getProfileById(otherUserId);
        if (otherUserProfile == null) continue;

        // Fetch messages for this conversation
        final messagesResponse = await _supabase
            .from('messages')
            .select()
            .eq('conversation_id', convData['id'])
            .order('created_at', ascending: true);

        final messages = <ChatMessage>[];
        if (messagesResponse.isNotEmpty) {
          for (final msgData in messagesResponse) {
            final message = await _mapToChatMessage(msgData, userId, otherUserProfile);
            messages.add(message);
          }
        }

        // Get last message time
        DateTime lastMessageTime = convData['started_at'] != null
            ? DateTime.parse(convData['started_at'])
            : DateTime.now();

        if (messages.isNotEmpty) {
          lastMessageTime = messages.last.timestamp;
        }

        // Count unread messages (messages not seen by current user)
        final unreadCount = messages.where((msg) => 
          msg.senderId != userId && !msg.isRead
        ).length;

        conversations.add(ChatConversation(
          id: convData['id'].toString(),
          otherUser: otherUserProfile,
          messages: messages,
          lastMessageTime: lastMessageTime,
          unreadCount: unreadCount,
        ));
      }

      return conversations;
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<ChatMessage> _mapToChatMessage(
    Map<String, dynamic> data, 
    String currentUserId,
    UserProfile otherUser,
  ) async {
    final senderId = data['sender']?.toString() ?? '';
    String senderName;
    
    if (senderId == currentUserId) {
      senderName = 'You';
    } else {
      // Use the other user's display name
      senderName = otherUser.displayName;
    }
    
    return ChatMessage(
      id: data['id']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      content: data['content'] ?? '',
      timestamp: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      isRead: data['seen'] ?? false,
    );
  }
}
