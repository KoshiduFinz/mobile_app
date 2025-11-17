import 'chat_message.dart';
import 'user_profile.dart';

class ChatConversation {
  final String id;
  final UserProfile otherUser;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.otherUser,
    required this.messages,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  String get lastMessage {
    if (messages.isEmpty) return 'No messages';
    return messages.last.content;
  }

  bool get hasUnread => unreadCount > 0;
}

