import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/domain/repositories/chat_repository.dart';

class SendMessage implements UseCase<void, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);
  @override
  Future<Either<Failure, void>> call(SendMessageParams params) async {
    return await repository.sendMessage(params.message);
  }
}

class SendMessageParams extends Equatable {
  final MessageEntity message;

  const SendMessageParams({required this.message});

  @override
  List<Object> get props => [message];
}
