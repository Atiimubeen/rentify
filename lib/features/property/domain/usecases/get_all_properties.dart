import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class GetAllProperties implements UseCase<List<PropertyEntity>, NoParams> {
  final PropertyRepository repository;

  GetAllProperties(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(NoParams params) async {
    return await repository.getAllProperties();
  }
}
