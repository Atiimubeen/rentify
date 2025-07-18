import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_event.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_state.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String chatRoomId;

  ChatPage({super.key, required this.currentUserId, required this.otherUserId})
    : chatRoomId = _createChatRoomId(currentUserId, otherUserId);

  // Helper method to create a consistent chat room ID
  static String _createChatRoomId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load messages when the screen is opened
    context.read<ChatBloc>().add(LoadMessagesEvent(widget.chatRoomId));
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = MessageEntity(
      id: const Uuid().v4(),
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      text: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendTextMessageEvent(message));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesLoaded) {
                  return ListView.builder(
                    reverse: true, // To show latest messages at the bottom
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == widget.currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                }
                if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('No messages yet.'));
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
