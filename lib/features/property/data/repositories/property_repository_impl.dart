import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/network/network_info.dart';
import 'package:rentify/features/property/data/datasources/property_remote_data_source.dart';
import 'package:rentify/features/property/data/models/property_model.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, PropertyEntity>> getPropertyById(
    String propertyId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final property = await remoteDataSource.getPropertyById(propertyId);
        return Right(property);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> addProperty({
    required PropertyEntity property,
    required List<File> images,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final propertyModel = PropertyModel(
          id: property.id,
          landlordId: property.landlordId,
          title: property.title,
          description: property.description,
          rent: property.rent,
          address: property.address,
          sizeSqft: property.sizeSqft,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          imageUrls: property.imageUrls,
          isAvailable: property.isAvailable,
          postedDate: property.postedDate,
        );
        await remoteDataSource.addProperty(propertyModel, images);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getAllProperties() async {
    if (await networkInfo.isConnected) {
      try {
        final properties = await remoteDataSource.getAllProperties();
        return Right(properties);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByLandlord(
    String landlordId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final properties = await remoteDataSource.getPropertiesByLandlord(
          landlordId,
        );
        return Right(properties);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String propertyId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProperty(propertyId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePropertyAvailability(
    String propertyId,
    bool isAvailable,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updatePropertyAvailability(
          propertyId,
          isAvailable,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }
}
