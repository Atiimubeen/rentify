import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/property/data/models/property_model.dart';
import 'package:uuid/uuid.dart';

abstract class PropertyRemoteDataSource {
  Future<void> addProperty(PropertyModel property, List<File> images);
  Future<List<PropertyModel>> getAllProperties();
  Future<List<PropertyModel>> getPropertiesByLandlord(String landlordId);
  Future<void> deleteProperty(String propertyId);
  Future<void> updatePropertyAvailability(String propertyId, bool isAvailable);
  Future<PropertyModel> getPropertyById(String propertyId);
}

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
      List<String> imageUrls = [];
      for (var image in images) {
        String imageId = uuid.v4();
        final ref = storage.ref().child('property_images').child(imageId);
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      final propertyToSave = PropertyModel(
        id: property.id,
        landlordId: property.landlordId,
        title: property.title,
        description: property.description,
        rent: property.rent,
        address: property.address,
        sizeSqft: property.sizeSqft,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        imageUrls: imageUrls,
        isAvailable: property.isAvailable,
        postedDate: property.postedDate,
      );

      await firestore
          .collection('properties')
          .add(propertyToSave.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firebase error occurred');
    }
  }

  @override
  Future<PropertyModel> getPropertyById(String propertyId) async {
    try {
      final doc = await firestore
          .collection('properties')
          .doc(propertyId)
          .get();
      if (doc.exists) {
        return PropertyModel.fromFirestore(doc);
      } else {
        throw ServerException('Property not found.');
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get property details.');
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
    }
  }

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
      throw ServerException(e.message ?? 'Failed to fetch properties.');
    }
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    try {
      await firestore.collection('properties').doc(propertyId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete property.');
    }
  }

  @override
  Future<void> updatePropertyAvailability(
    String propertyId,
    bool isAvailable,
  ) async {
    try {
      await firestore.collection('properties').doc(propertyId).update({
        'isAvailable': isAvailable,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update property status.');
    }
  }
}
