import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);
  Stream<List<MessageModel>> getMessages(String chatRoomId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      // Create a unique chat room ID from sender and receiver IDs
      // This ensures the same chat room is used regardless of who sends the first message
      List<String> ids = [message.senderId, message.receiverId];
      ids.sort(); // Sort the IDs to ensure consistency
      String chatRoomId = ids.join('_');

      // Add the new message to the 'messages' subcollection of the chat room
      await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to send message.');
    }
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatRoomId) {
    try {
      final snapshots = firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      return snapshots.map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      // Return a stream that emits an error
      return Stream.error(ServerException('Failed to get messages.'));
    }
  }
}
