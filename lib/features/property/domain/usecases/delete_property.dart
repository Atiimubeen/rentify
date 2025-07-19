import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class DeleteProperty implements UseCase<void, DeletePropertyParams> {
  final PropertyRepository repository;

  DeleteProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePropertyParams params) async {
    return await repository.deleteProperty(params.propertyId);
  }
}

class DeletePropertyParams extends Equatable {
  final String propertyId;

  const DeletePropertyParams(this.propertyId);

  @override
  List<Object> get props => [propertyId];
}
