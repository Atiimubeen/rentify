import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
// --- YEH IMPORT LINE MISSING THI ---
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class GetPropertyById
    implements UseCase<PropertyEntity, GetPropertyByIdParams> {
  final PropertyRepository repository;

  GetPropertyById(this.repository);

  @override
  Future<Either<Failure, PropertyEntity>> call(
    GetPropertyByIdParams params,
  ) async {
    return await repository.getPropertyById(params.propertyId);
  }
}

class GetPropertyByIdParams extends Equatable {
  final String propertyId;

  const GetPropertyByIdParams(this.propertyId);

  @override
  List<Object> get props => [propertyId];
}
