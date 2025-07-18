import 'package:equatable/equatable.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

// Ek chat room ke saare messages haasil karna
class LoadMessagesEvent extends ChatEvent {
  final String chatRoomId;

  const LoadMessagesEvent(this.chatRoomId);
}

// Naya message bhejna
class SendTextMessageEvent extends ChatEvent {
  final MessageEntity message;

  const SendTextMessageEvent(this.message);
}
