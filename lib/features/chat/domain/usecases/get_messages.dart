import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/domain/repositories/chat_repository.dart';

// Note: This usecase is slightly different as it returns a Stream
class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Stream<Either<Failure, List<MessageEntity>>> call(GetMessagesParams params) {
    return repository.getMessages(params.chatRoomId);
  }
}

class GetMessagesParams extends Equatable {
  final String chatRoomId;

  const GetMessagesParams({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}
