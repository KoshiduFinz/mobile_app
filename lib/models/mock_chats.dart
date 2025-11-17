import 'chat_conversation.dart';
import 'chat_message.dart';
import 'mock_profiles.dart';

class MockChats {
  static List<ChatConversation> getConversations() {
    final profiles = MockProfiles.getProfiles();
    
    return [
      ChatConversation(
        id: '1',
        otherUser: profiles[0], // Priya
        messages: [
          ChatMessage(
            id: '1',
            senderId: 'current_user',
            senderName: 'You',
            content: 'Hi Priya! How are you?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: true,
          ),
          ChatMessage(
            id: '2',
            senderId: profiles[0].id,
            senderName: profiles[0].displayName,
            content: 'Hello! I\'m doing great, thanks for asking. How about you?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
            isRead: true,
          ),
          ChatMessage(
            id: '3',
            senderId: 'current_user',
            senderName: 'You',
            content: 'I\'m good too! Would you like to meet up sometime?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
            isRead: true,
          ),
          ChatMessage(
            id: '4',
            senderId: profiles[0].id,
            senderName: profiles[0].displayName,
            content: 'That sounds great! I\'m free this weekend.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            isRead: false,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
        unreadCount: 1,
      ),
      ChatConversation(
        id: '2',
        otherUser: profiles[1], // Ravi
        messages: [
          ChatMessage(
            id: '5',
            senderId: profiles[1].id,
            senderName: profiles[1].displayName,
            content: 'Hi there! I saw your profile and I think we have a lot in common.',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
            isRead: true,
          ),
          ChatMessage(
            id: '6',
            senderId: 'current_user',
            senderName: 'You',
            content: 'Hello Ravi! Yes, I noticed that too. What are your interests?',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            isRead: true,
          ),
          ChatMessage(
            id: '7',
            senderId: profiles[1].id,
            senderName: profiles[1].displayName,
            content: 'I love cricket and reading business books. How about you?',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
      ChatConversation(
        id: '3',
        otherUser: profiles[2], // Anjali
        messages: [
          ChatMessage(
            id: '8',
            senderId: 'current_user',
            senderName: 'You',
            content: 'Hi Anjali! I\'m impressed by your profession. How do you balance work and personal life?',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
            isRead: true,
          ),
          ChatMessage(
            id: '9',
            senderId: profiles[2].id,
            senderName: profiles[2].displayName,
            content: 'Thank you! It\'s all about time management and having supportive people around.',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
            isRead: true,
          ),
          ChatMessage(
            id: '10',
            senderId: profiles[2].id,
            senderName: profiles[2].displayName,
            content: 'What do you do for work?',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
            isRead: false,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        unreadCount: 1,
      ),
      ChatConversation(
        id: '4',
        otherUser: profiles[3], // Dilshan
        messages: [
          ChatMessage(
            id: '11',
            senderId: profiles[3].id,
            senderName: profiles[3].displayName,
            content: 'Hey! I see you\'re into tech too. What programming languages do you work with?',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            isRead: true,
          ),
          ChatMessage(
            id: '12',
            senderId: 'current_user',
            senderName: 'You',
            content: 'Hi Dilshan! I work with Flutter and Dart. How about you?',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 20)),
            isRead: true,
          ),
          ChatMessage(
            id: '13',
            senderId: profiles[3].id,
            senderName: profiles[3].displayName,
            content: 'That\'s awesome! I work with Python and JavaScript mostly.',
            timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 19)),
            isRead: true,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(days: 2, hours: 19)),
        unreadCount: 0,
      ),
      ChatConversation(
        id: '5',
        otherUser: profiles[4], // Nisha
        messages: [
          ChatMessage(
            id: '14',
            senderId: 'current_user',
            senderName: 'You',
            content: 'Hi Nisha! I love your interest in art and photography.',
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
            isRead: true,
          ),
          ChatMessage(
            id: '15',
            senderId: profiles[4].id,
            senderName: profiles[4].displayName,
            content: 'Thank you! Art is my passion. Do you have any artistic hobbies?',
            timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 22)),
            isRead: true,
          ),
        ],
        lastMessageTime: DateTime.now().subtract(const Duration(days: 3, hours: 22)),
        unreadCount: 0,
      ),
    ];
  }
}

