import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';
import '../constants/app_constants.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/supabase_client.dart';

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
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final SupabaseClient _supabase = SupabaseService.client;
  
  String? _conversationId;
  String? _currentUserId;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  RealtimeChannel? _messageChannel;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user ID
      _currentUserId = _authService.currentUser?.id;
      if (_currentUserId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get or create conversation
      _conversationId = widget.conversationId;
      if (_conversationId == null) {
        _conversationId = await _chatService.getOrCreateConversation(widget.profile.id);
      }

      // Load initial messages
      if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
        _messages = widget.initialMessages!;
        setState(() {
          _isLoading = false;
        });
      } else {
        await _loadMessages();
      }

      // Mark messages as read
      if (_conversationId != null) {
        await _chatService.markMessagesAsRead(_conversationId!);
      }

      // Set up real-time subscription
      _setupRealtimeSubscription();

      // Scroll to bottom when messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;
    
    try {
      final messages = await _chatService.getMessages(_conversationId!);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupRealtimeSubscription() {
    if (_conversationId == null) return;

    // Subscribe to new messages in this conversation
    _messageChannel = _supabase
        .channel('messages_${_conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: _conversationId,
          ),
          callback: (payload) {
            _handleNewMessage(payload.newRecord);
          },
        )
        .subscribe();

    // Also listen for updates (e.g., when messages are marked as read)
    _supabase
        .channel('messages_update_${_conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: _conversationId,
          ),
          callback: (payload) {
            _handleMessageUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  void _handleNewMessage(Map<String, dynamic> messageData) async {
    try {
      final senderId = messageData['sender']?.toString() ?? '';
      
      // Don't add the message if it's from the current user (already added optimistically)
      if (senderId == _currentUserId) {
        // Update the message with the actual data from database
        final messageId = messageData['id']?.toString();
        final index = _messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          // Message already exists, might just need to update
          return;
        }
      }

      // Get sender profile
      final senderProfile = await _profileService.getProfileById(senderId);
      final senderName = senderId == _currentUserId 
          ? 'You' 
          : (senderProfile?.displayName ?? 'Unknown');

      final newMessage = ChatMessage(
        id: messageData['id']?.toString() ?? '',
        senderId: senderId,
        senderName: senderName,
        content: messageData['content'] ?? '',
        timestamp: messageData['created_at'] != null
            ? DateTime.parse(messageData['created_at'])
            : DateTime.now(),
        isRead: messageData['seen'] ?? false,
      );

      if (mounted) {
        setState(() {
          // Check if message already exists to avoid duplicates
          if (!_messages.any((msg) => msg.id == newMessage.id)) {
            _messages.add(newMessage);
          }
        });
        _scrollToBottom();
        
        // Mark as read if it's from another user
        if (senderId != _currentUserId && _conversationId != null) {
          await _chatService.markMessagesAsRead(_conversationId!);
        }
      }
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  void _handleMessageUpdate(Map<String, dynamic> messageData) {
    final messageId = messageData['id']?.toString();
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1 && mounted) {
      setState(() {
        _messages[index] = ChatMessage(
          id: _messages[index].id,
          senderId: _messages[index].senderId,
          senderName: _messages[index].senderName,
          content: _messages[index].content,
          timestamp: _messages[index].timestamp,
          isRead: messageData['seen'] ?? false,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _conversationId == null || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Send message to Supabase
      final sentMessage = await _chatService.sendMessage(
        conversationId: _conversationId!,
        content: text,
      );

      // Add message to local list (real-time will also add it, but this ensures immediate UI update)
      if (mounted) {
        setState(() {
          // Check if message already exists (from real-time)
          if (!_messages.any((msg) => msg.id == sentMessage.id)) {
            _messages.add(sentMessage);
          }
          _isSending = false;
        });
        _messageController.clear();
        _scrollToBottom();
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        foregroundColor: Colors.white,
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
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.gradientRoyal,
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _messages.isEmpty
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
                                gradient: isCurrentUser
                                    ? AppConstants.gradientRoyal
                                    : null,
                                color: isCurrentUser
                                    ? null
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
                    gradient: AppConstants.gradientGold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSending ? null : _sendMessage,
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

