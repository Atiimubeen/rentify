import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id; // Combination of user IDs
  final List<String> userIds; // [tenantId, landlordId]
  final String lastMessage;
  final DateTime lastMessageTimestamp;

  const ChatRoomEntity({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  @override
  List<Object?> get props => [id, userIds, lastMessage, lastMessageTimestamp];
}
