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

// Nai property add karne ke liye
class AddNewPropertyEvent extends PropertyEvent {
  final PropertyEntity property;
  final List<File> images;

  const AddNewPropertyEvent({required this.property, required this.images});

  @override
  List<Object> get props => [property, images];
}
// ... baaki events wese hi rahenge ...

// Landlord ki properties fetch karne ke liye
class FetchLandlordPropertiesEvent extends PropertyEvent {
  final String landlordId;

  const FetchLandlordPropertiesEvent(this.landlordId);

  @override
  List<Object> get props => [landlordId];
}
