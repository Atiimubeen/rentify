import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class AddProperty implements UseCase<void, AddPropertyParams> {
  final PropertyRepository repository;

  AddProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(AddPropertyParams params) async {
    return await repository.addProperty(
      property: params.property,
      images: params.images,
    );
  }
}

class AddPropertyParams extends Equatable {
  final PropertyEntity property;
  final List<File> images;

  const AddPropertyParams({required this.property, required this.images});

  @override
  List<Object> get props => [property, images];
}
