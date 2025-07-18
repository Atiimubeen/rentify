import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class GetPropertiesByLandlord
    implements UseCase<List<PropertyEntity>, GetPropertiesByLandlordParams> {
  final PropertyRepository repository;

  GetPropertiesByLandlord(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(
    GetPropertiesByLandlordParams params,
  ) async {
    return await repository.getPropertiesByLandlord(params.landlordId);
  }
}

class GetPropertiesByLandlordParams extends Equatable {
  final String landlordId;

  const GetPropertiesByLandlordParams(this.landlordId);

  @override
  List<Object> get props => [landlordId];
}
