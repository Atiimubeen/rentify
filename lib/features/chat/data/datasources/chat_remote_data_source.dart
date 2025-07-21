import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/chat/data/models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);
  Stream<List<MessageModel>> getMessages(String chatRoomId);
  Future<void> deleteMessage(String chatRoomId, String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete message.');
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      List<String> ids = [message.senderId, message.receiverId];
      ids.sort();
      String chatRoomId = ids.join('_');

      // 1. Pehle chat room ka document banayein ya update karein
      // Is se security rules kaam karengy aur hum chat list bhi bana saktay hain
      await firestore.collection('chat_rooms').doc(chatRoomId).set({
        'userIds': ids,
        'lastMessage': message.text,
        'lastMessageTimestamp': message.timestamp,
      }, SetOptions(merge: true)); // merge: true taake purana data delete na ho

      // 2. Ab message ko uske subcollection mein add karein
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
      return Stream.error(ServerException('Failed to get messages.'));
    }
  }
}
