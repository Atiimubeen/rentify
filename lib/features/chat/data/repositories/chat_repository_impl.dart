import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/exceptions.dart';

import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:rentify/features/chat/data/models/message_model.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';
import 'package:rentify/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> deleteMessage(
    String chatRoomId,
    String messageId,
  ) async {
    try {
      await remoteDataSource.deleteMessage(chatRoomId, messageId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageEntity message) async {
    try {
      final messageModel = MessageModel(
        id: message.id,
        senderId: message.senderId,
        receiverId: message.receiverId,
        text: message.text,
        timestamp: message.timestamp,
      );
      await remoteDataSource.sendMessage(messageModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId) {
    try {
      final messageStream = remoteDataSource.getMessages(chatRoomId);
      return messageStream.map((messages) => Right(messages));
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    }
  }
}
