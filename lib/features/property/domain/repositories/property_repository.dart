import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';

abstract class PropertyRepository {
  Future<Either<Failure, void>> deleteProperty(String propertyId);
  Future<Either<Failure, void>> updatePropertyAvailability(
    String propertyId,
    bool isAvailable,
  );
  Future<Either<Failure, PropertyEntity>> getPropertyById(String propertyId);
  // Landlord ke liye: Nai property add karna
  Future<Either<Failure, void>> addProperty({
    required PropertyEntity property,
    required List<File> images, // Raw image files from device
  });

  // Tenant ke liye: Saari properties dekhna
  Future<Either<Failure, List<PropertyEntity>>> getAllProperties();

  // Landlord ke liye: Sirf apni properties dekhna
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByLandlord(
    String landlordId,
  );
}
