import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfile implements UseCase<UserEntity, GetUserProfileParams> {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetUserProfileParams params) async {
    return await repository.getUserProfile(params.uid);
  }
}

class GetUserProfileParams extends Equatable {
  final String uid;
  const GetUserProfileParams(this.uid);
  @override
  List<Object> get props => [uid];
}
