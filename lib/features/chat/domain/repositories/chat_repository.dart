import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  // Naya message bhejna
  Future<Either<Failure, void>> sendMessage(MessageEntity message);

  // Ek specific chat room ke saare messages haasil karna (real-time)
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId);
}
