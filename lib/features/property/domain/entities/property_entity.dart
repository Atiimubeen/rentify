import 'package:equatable/equatable.dart';

class PropertyEntity extends Equatable {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final double rent;
  final String address;
  final double sizeSqft;
  final int bedrooms;
  final int bathrooms;
  final List<String> imageUrls; // Max 5 images
  final bool isAvailable;
  final DateTime postedDate;

  const PropertyEntity({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.rent,
    required this.address,
    required this.sizeSqft,
    required this.bedrooms,
    required this.bathrooms,
    required this.imageUrls,
    required this.isAvailable,
    required this.postedDate,
  });

  @override
  List<Object?> get props => [
    id,
    landlordId,
    title,
    description,
    rent,
    address,
    sizeSqft,
    bedrooms,
    bathrooms,
    imageUrls,
    isAvailable,
    postedDate,
  ];
}
