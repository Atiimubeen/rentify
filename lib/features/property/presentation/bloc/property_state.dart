import 'package:equatable/equatable.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object> get props => [];
}

// Initial state
class PropertyInitial extends PropertyState {}

// Jab data load ho raha ho
class PropertyLoading extends PropertyState {}

// Jab properties successfully load ho jayein
class PropertiesLoaded extends PropertyState {
  final List<PropertyEntity> properties;

  const PropertiesLoaded(this.properties);

  @override
  List<Object> get props => [properties];
}

// Jab property successfully add ho jaye
class PropertyAdded extends PropertyState {}

// Jab koi error aaye
class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object> get props => [message];
}
