import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/domain/usecases/get_messages.dart';
import 'package:rentify/features/chat/domain/usecases/send_message.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage _sendMessage;
  final GetMessages _getMessages;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required SendMessage sendMessage, required GetMessages getMessages})
    : _sendMessage = sendMessage,
      _getMessages = getMessages,
      super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendTextMessageEvent>(_onSendTextMessage);
    // Naya event jo stream se anay walay updates ko handle karega
    on<_MessagesUpdatedEvent>(_onMessagesUpdated);
  }

  void _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) {
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription =
        _getMessages(GetMessagesParams(chatRoomId: event.chatRoomId)).listen((
          result,
        ) {
          result.fold(
            // Agar stream se error aaye
            (failure) => add(_ErrorOccurredEvent(failure.message)),
            // Agar stream se naye messages aayein
            (messages) => add(_MessagesUpdatedEvent(messages)),
          );
        });
  }

  // Yeh private event handler hai jo sirf stream se data receive karta hai
  void _onMessagesUpdated(
    _MessagesUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(MessagesLoaded(event.messages));
  }

  // Yeh private event handler hai jo sirf stream se error receive karta hai
  void _onErrorOccurred(_ErrorOccurredEvent event, Emitter<ChatState> emit) {
    emit(ChatError(event.message));
  }

  void _onSendTextMessage(
    SendTextMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Message bhejte waqt hum state change nahi karengy taake UI smooth rahe
    final result = await _sendMessage(
      SendMessageParams(message: event.message),
    );
    result.fold((failure) => emit(ChatError(failure.message)), (_) {
      // Message Sent state ki ab zaroorat nahi, kyunke stream khud hi UI update kar degi
    });
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

// --- Private Events (Sirf is BLoC ke andar istemal hongy) ---

class _MessagesUpdatedEvent extends ChatEvent {
  final List<MessageEntity> messages;
  const _MessagesUpdatedEvent(this.messages);
}

class _ErrorOccurredEvent extends ChatEvent {
  final String message;
  const _ErrorOccurredEvent(this.message);
}
