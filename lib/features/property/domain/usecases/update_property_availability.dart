import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class UpdatePropertyAvailability
    implements UseCase<void, UpdatePropertyAvailabilityParams> {
  final PropertyRepository repository;

  UpdatePropertyAvailability(this.repository);

  @override
  Future<Either<Failure, void>> call(
    UpdatePropertyAvailabilityParams params,
  ) async {
    return await repository.updatePropertyAvailability(
      params.propertyId,
      params.isAvailable,
    );
  }
}

class UpdatePropertyAvailabilityParams extends Equatable {
  final String propertyId;
  final bool isAvailable;

  const UpdatePropertyAvailabilityParams({
    required this.propertyId,
    required this.isAvailable,
  });

  @override
  List<Object> get props => [propertyId, isAvailable];
}
