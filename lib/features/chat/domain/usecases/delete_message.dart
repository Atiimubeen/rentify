import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/chat/domain/repositories/chat_repository.dart';

class DeleteMessage implements UseCase<void, DeleteMessageParams> {
  final ChatRepository repository;
  DeleteMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMessageParams params) async {
    return await repository.deleteMessage(params.chatRoomId, params.messageId);
  }
}

class DeleteMessageParams extends Equatable {
  final String chatRoomId;
  final String messageId;
  const DeleteMessageParams({
    required this.chatRoomId,
    required this.messageId,
  });
  @override
  List<Object> get props => [chatRoomId, messageId];
}
