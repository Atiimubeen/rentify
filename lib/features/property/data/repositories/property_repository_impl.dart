import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/network/network_info.dart';
import 'package:rentify/features/property/data/datasources/property_remote_data_source.dart';
import 'package:rentify/features/property/data/models/property_model.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/domain/repositories/property_repository.dart';
import 'package:rentify/features/property/domain/usecases/get_properties_by_landlord.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> addProperty({
    required PropertyEntity property,
    required List<File> images,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // We need to cast the PropertyEntity to a PropertyModel to pass it to the data source.
        // The ID can be temporary as Firestore will generate a new one.
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
          imageUrls: property.imageUrls, // Will be replaced by datasource
          isAvailable: property.isAvailable,
          postedDate: property.postedDate,
        );
        await remoteDataSource.addProperty(propertyModel, images);
        return const Right(null); // Use Right(null) for void success
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
        return Right(
          properties,
        ); // The models are subtypes of entities, so this is fine.
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
    // Note: The remote data source doesn't have a method for this yet.
    // We would need to add a 'getPropertiesByLandlord' method to the data source
    // that queries Firestore with a 'where' clause on 'landlordId'.
    // For now, we can return an empty list or a failure.
    return Left(ServerFailure('This feature is not yet implemented.'));
  }
  // ... addProperty aur getAllProperties ke methods wese hi rahenge ...

  @override
  Future<Either<Failure, List<PropertyEntity>>> GetPropertiesByLandlord(
    String landlordId,
  ) async {
    // --- IS METHOD KA CODE UPDATE KAREIN ---
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
}
