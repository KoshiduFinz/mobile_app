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
        try {
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
        } catch (e) {
          print('Error processing conversation: $e');
          continue;
        }
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

  // Get messages for a specific conversation
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final List<ChatMessage> messages = [];
      for (final msgData in response) {
        final senderId = msgData['sender']?.toString() ?? '';
        final senderProfile = await _profileService.getProfileById(senderId);
        
        messages.add(ChatMessage(
          id: msgData['id']?.toString() ?? '',
          senderId: senderId,
          senderName: senderId == user.id 
              ? 'You' 
              : (senderProfile?.displayName ?? 'Unknown'),
          content: msgData['content'] ?? '',
          timestamp: msgData['created_at'] != null
              ? DateTime.parse(msgData['created_at'])
              : DateTime.now(),
          isRead: msgData['seen'] ?? false,
        ));
      }

      return messages;
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  // Send a message
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender': user.id,
            'content': content,
            'seen': false,
          })
          .select()
          .single();

      return ChatMessage(
        id: response['id']?.toString() ?? '',
        senderId: user.id,
        senderName: 'You',
        content: response['content'] ?? '',
        timestamp: response['created_at'] != null
            ? DateTime.parse(response['created_at'])
            : DateTime.now(),
        isRead: response['seen'] ?? false,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Create or get conversation with another user
  Future<String> getOrCreateConversation(String otherUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Try to find existing conversation
      final existingResponse = await _supabase
          .from('conversations')
          .select()
          .or('participant_one.eq.$user.id,participant_two.eq.$user.id')
          .or('participant_one.eq.$otherUserId,participant_two.eq.$otherUserId');

      // Check if conversation exists with both participants
      for (var conv in existingResponse) {
        final participantOne = conv['participant_one']?.toString();
        final participantTwo = conv['participant_two']?.toString();
        if ((participantOne == user.id || participantTwo == user.id) &&
            (participantOne == otherUserId || participantTwo == otherUserId)) {
          return conv['id'].toString();
        }
      }

      // Create new conversation
      final convResponse = await _supabase
          .from('conversations')
          .insert({
            'participant_one': user.id,
            'participant_two': otherUserId,
            'started_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      return convResponse['id'].toString();
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase
          .from('messages')
          .update({'seen': true})
          .eq('conversation_id', conversationId)
          .neq('sender', user.id)
          .eq('seen', false);
    } catch (e) {
      // Ignore errors for marking as read
      print('Error marking messages as read: $e');
    }
  }
}
