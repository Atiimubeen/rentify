import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/domain/usecases/delete_message.dart';
import 'package:rentify/features/chat/domain/usecases/get_messages.dart';
import 'package:rentify/features/chat/domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage _sendMessage;
  final GetMessages _getMessages;
  final DeleteMessage _deleteMessage; // <<< USE CASE
  StreamSubscription? _messagesSubscription;

  ChatBloc({
    required SendMessage sendMessage,
    required GetMessages getMessages,
    required DeleteMessage deleteMessage, // <<< CONSTRUCTOR
  }) : _sendMessage = sendMessage,
       _getMessages = getMessages,
       _deleteMessage = deleteMessage, // <<< INITIALIZED
       super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendTextMessageEvent>(_onSendTextMessage);
    on<_MessagesUpdatedEvent>(_onMessagesUpdated);
    on<_ErrorOccurredEvent>(_onErrorOccurred);
    on<DeleteMessageEvent>(_onDeleteMessage); // <<< YEH HANDLER MISSING THA
  }

  void _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription =
        _getMessages(GetMessagesParams(chatRoomId: event.chatRoomId)).listen((
          result,
        ) {
          result.fold(
            (failure) => add(_ErrorOccurredEvent(failure.message)),
            (messages) => add(_MessagesUpdatedEvent(messages)),
          );
        });
  }

  void _onMessagesUpdated(
    _MessagesUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(MessagesLoaded(event.messages));
  }

  void _onErrorOccurred(_ErrorOccurredEvent event, Emitter<ChatState> emit) {
    emit(ChatError(event.message));
  }

  void _onSendTextMessage(
    SendTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _sendMessage(
      SendMessageParams(message: event.message),
    );
    result.fold((failure) => emit(ChatError(failure.message)), (_) {});
  }

  // --- YEH NAYA METHOD ADD HUA HAI ---
  void _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _deleteMessage(
      DeleteMessageParams(
        chatRoomId: event.chatRoomId,
        messageId: event.messageId,
      ),
    );
    // Humein state emit karne ki zaroorat nahi, stream khud hi UI update kar degi
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

// --- Private Events ---

class _MessagesUpdatedEvent extends ChatEvent {
  final List<MessageEntity> messages;
  const _MessagesUpdatedEvent(this.messages);
}

class _ErrorOccurredEvent extends ChatEvent {
  final String message;
  const _ErrorOccurredEvent(this.message);
}
