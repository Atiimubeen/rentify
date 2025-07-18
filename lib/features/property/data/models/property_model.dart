import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.landlordId,
    required super.title,
    required super.description,
    required super.rent,
    required super.address,
    required super.sizeSqft,
    required super.bedrooms,
    required super.bathrooms,
    required super.imageUrls,
    required super.isAvailable,
    required super.postedDate,
  });

  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PropertyModel(
      id: doc.id,
      landlordId: data['landlordId'],
      title: data['title'],
      description: data['description'],
      rent: (data['rent'] as num).toDouble(),
      address: data['address'],
      sizeSqft: (data['sizeSqft'] as num).toDouble(),
      bedrooms: data['bedrooms'],
      bathrooms: data['bathrooms'],
      imageUrls: List<String>.from(data['imageUrls']),
      isAvailable: data['isAvailable'],
      postedDate: (data['postedDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'landlordId': landlordId,
      'title': title,
      'description': description,
      'rent': rent,
      'address': address,
      'sizeSqft': sizeSqft,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'postedDate': Timestamp.fromDate(postedDate),
    };
  }
}
