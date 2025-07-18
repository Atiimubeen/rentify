import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? role; // 'landlord' ya 'tenant'

  const UserEntity({
    required this.uid,
    this.email,
    this.name,
    this.photoUrl,
    this.role,
  });

  @override
  List<Object?> get props => [uid, email, name, photoUrl, role];
}
