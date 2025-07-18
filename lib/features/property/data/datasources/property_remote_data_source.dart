import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/property/data/models/property_model.dart';
import 'package:uuid/uuid.dart';

// --- Contract for the data source ---
abstract class PropertyRemoteDataSource {
  Future<void> addProperty(PropertyModel property, List<File> images);
  Future<List<PropertyModel>> getAllProperties();
  // Method to fetch properties for a specific landlord
  Future<List<PropertyModel>> getPropertiesByLandlord(String landlordId);
}

// --- Implementation of the data source ---
class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final Uuid uuid;

  PropertyRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.uuid,
  });

  @override
  Future<void> addProperty(PropertyModel property, List<File> images) async {
    try {
      // 1. Upload images to Firebase Storage
      List<String> imageUrls = [];
      for (var image in images) {
        String imageId = uuid.v4();
        final ref = storage.ref().child('property_images').child(imageId);
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      // 2. Create a new PropertyModel with the uploaded image URLs
      final propertyToSave = PropertyModel(
        id: property.id, // ID will be set by Firestore
        landlordId: property.landlordId,
        title: property.title,
        description: property.description,
        rent: property.rent,
        address: property.address,
        sizeSqft: property.sizeSqft,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        imageUrls: imageUrls, // Use the new URLs
        isAvailable: property.isAvailable,
        postedDate: property.postedDate,
      );

      // 3. Save property data to Firestore
      await firestore
          .collection('properties')
          .add(propertyToSave.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error occurred');
    } catch (e) {
      throw ServerException('An unknown error occurred');
    }
  }

  @override
  Future<List<PropertyModel>> getAllProperties() async {
    try {
      final snapshot = await firestore
          .collection('properties')
          .where('isAvailable', isEqualTo: true)
          .orderBy('postedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error occurred');
    } catch (e) {
      throw ServerException('An unknown error occurred');
    }
  }

  // --- Implementation of the new method ---
  @override
  Future<List<PropertyModel>> getPropertiesByLandlord(String landlordId) async {
    try {
      final snapshot = await firestore
          .collection('properties')
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('postedDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PropertyModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error occurred');
    } catch (e) {
      throw ServerException('An unknown error occurred');
    }
  }
}
