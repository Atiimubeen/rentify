import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object> get props => [];
}

// Saari properties fetch karne ke liye
class FetchAllPropertiesEvent extends PropertyEvent {}

// Landlord ki properties fetch karne ke liye
class FetchLandlordPropertiesEvent extends PropertyEvent {
  final String landlordId;
  const FetchLandlordPropertiesEvent(this.landlordId);
}

// Nai property add karne ke liye
class AddNewPropertyEvent extends PropertyEvent {
  final PropertyEntity property;
  final List<File> images;
  final String landlordId;
  const AddNewPropertyEvent({
    required this.property,
    required this.images,
    required this.landlordId,
  });

  @override
  List<Object> get props => [property, images, landlordId];
}

class FetchPropertyByIdEvent extends PropertyEvent {
  final String propertyId;
  const FetchPropertyByIdEvent(this.propertyId);
}

// --- YEH NAYA EVENT ADD HUA HAI ---
// Property delete karne ke liye
class DeletePropertyEvent extends PropertyEvent {
  final String propertyId;
  final String landlordId; // List refresh karne ke liye

  const DeletePropertyEvent({
    required this.propertyId,
    required this.landlordId,
  });

  @override
  List<Object> get props => [propertyId, landlordId];
}
