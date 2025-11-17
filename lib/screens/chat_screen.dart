import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final UserProfile profile;
  final String? conversationId;
  final List<ChatMessage>? initialMessages;

  const ChatScreen({
    super.key,
    required this.profile,
    this.conversationId,
    this.initialMessages,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = 'current_user';
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages = widget.initialMessages ?? [];
    // Scroll to bottom when messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      senderName: 'You',
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate a reply after a delay (mock)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final replyMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: widget.profile.id,
          senderName: widget.profile.displayName,
          content: _generateMockReply(text),
          timestamp: DateTime.now(),
          isRead: false,
        );

        setState(() {
          _messages.add(replyMessage);
        });
        _scrollToBottom();
      }
    });
  }

  String _generateMockReply(String userMessage) {
    // Simple mock reply generator
    final lowerMessage = userMessage.toLowerCase();
    if (lowerMessage.contains('hi') || lowerMessage.contains('hello')) {
      return 'Hello! How can I help you?';
    } else if (lowerMessage.contains('how are you')) {
      return 'I\'m doing great, thank you! How about you?';
    } else if (lowerMessage.contains('meet') || lowerMessage.contains('coffee')) {
      return 'That sounds great! I\'d love to meet up.';
    } else if (lowerMessage.contains('?')) {
      return 'That\'s an interesting question. Let me think about that.';
    } else {
      return 'Thanks for your message! I appreciate it.';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.profile.avatarUrl != null
                  ? NetworkImage(widget.profile.avatarUrl!)
                  : null,
              child: widget.profile.avatarUrl == null
                  ? Text(
                      widget.profile.displayName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    widget.profile.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation with ${widget.profile.displayName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isCurrentUser = message.senderId == _currentUserId;
                      final showTime = index == 0 ||
                          message.timestamp.difference(_messages[index - 1].timestamp).inMinutes > 5;

                      return Column(
                        crossAxisAlignment: isCurrentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (showTime)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _formatMessageTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          Align(
                            alignment: isCurrentUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(18).copyWith(
                                  bottomRight: isCurrentUser
                                      ? const Radius.circular(4)
                                      : null,
                                  bottomLeft: !isCurrentUser
                                      ? const Radius.circular(4)
                                      : null,
                                ),
                              ),
                              child: Text(
                                message.content,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

