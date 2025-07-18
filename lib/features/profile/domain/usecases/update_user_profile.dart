import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfile implements UseCase<void, UpdateUserProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(params.user);
  }
}

class UpdateUserProfileParams extends Equatable {
  final UserEntity user;
  const UpdateUserProfileParams(this.user);
  @override
  List<Object> get props => [user];
}
