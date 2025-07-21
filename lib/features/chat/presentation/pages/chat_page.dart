import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';

import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_event.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_state.dart';

import 'package:rentify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_event.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_state.dart';

import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final BookingEntity booking;
  final String chatRoomId;

  ChatPage({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.booking,
  }) : chatRoomId = _createChatRoomId(currentUserId, otherUserId);

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
  MessageEntity? _selectedMessage;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessagesEvent(widget.chatRoomId));
    context.read<ProfileBloc>().add(FetchProfileEvent(widget.otherUserId));
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

  void _copyMessage() {
    if (_selectedMessage != null) {
      Clipboard.setData(ClipboardData(text: _selectedMessage!.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message copied to clipboard')),
      );
      setState(() {
        _selectedMessage = null;
      });
    }
  }

  void _deleteMessage() {
    if (_selectedMessage != null) {
      context.read<ChatBloc>().add(
        DeleteMessageEvent(
          chatRoomId: widget.chatRoomId,
          messageId: _selectedMessage!.id,
        ),
      );
      setState(() {
        _selectedMessage = null;
      });
    }
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Deal'),
        content: const Text(
          'Are you sure you want to cancel this booking? The property will be listed as available again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookingBloc>().add(
                CancelBookingEvent(widget.booking),
              );
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedMessage == null
          ? _buildDefaultAppBar()
          : _buildSelectionAppBar(),
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
                    reverse: true,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == widget.currentUserId;

                      bool showDateDivider = false;
                      if (index == state.messages.length - 1 ||
                          !_isSameDay(
                            message.timestamp,
                            state.messages[index + 1].timestamp,
                          )) {
                        showDateDivider = true;
                      }

                      return Column(
                        children: [
                          if (showDateDivider)
                            _buildDateDivider(message.timestamp),
                          GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _selectedMessage = message;
                              });
                            },
                            child: _buildMessageBubble(
                              message,
                              isMe,
                              _selectedMessage?.id == message.id,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
                return const Center(child: Text('No messages yet. Say hi!'));
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  AppBar _buildDefaultAppBar() {
    final isLandlord = widget.currentUserId == widget.booking.landlordId;
    return AppBar(
      title: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoaded && state.user.uid == widget.otherUserId) {
            final otherUser = state.user;
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: (otherUser.photoUrl != null)
                      ? NetworkImage(otherUser.photoUrl!)
                      : null,
                  child: (otherUser.photoUrl == null)
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(otherUser.name ?? 'User'),
              ],
            );
          }
          return const Text('Chat');
        },
      ),
      actions: [
        if (isLandlord && widget.booking.status == BookingStatus.accepted)
          IconButton(
            icon: const Icon(Icons.cancel_schedule_send),
            tooltip: 'Cancel Deal',
            onPressed: _showCancelConfirmationDialog,
          ),
      ],
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _selectedMessage = null;
          });
        },
      ),
      title: const Text('1 selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          tooltip: 'Copy',
          onPressed: _copyMessage,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete',
          onPressed: _deleteMessage,
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildDateDivider(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat.yMMMd().format(timestamp);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageEntity message,
    bool isMe,
    bool isSelected,
  ) {
    return Container(
      color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(0),
              bottomRight: isMe
                  ? const Radius.circular(0)
                  : const Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(message.timestamp),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
