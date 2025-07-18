import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? role;
  final String? phone;
  final String? fcmToken;

  const UserEntity({
    required this.uid,
    this.email,
    this.name,
    this.photoUrl,
    this.role,
    this.fcmToken,
    this.phone, // <<< CONSTRUCTOR MEIN ADD KAREIN
  });

  @override
  List<Object?> get props => [uid, email, name, photoUrl, role, phone];
}
