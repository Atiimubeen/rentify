import 'package:equatable/equatable.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

// Jab messages successfully load ho jayein
class MessagesLoaded extends ChatState {
  final List<MessageEntity> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

// Jab message successfully bhej diya jaye
class MessageSent extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
