import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/usecases/add_property.dart';
import 'package:rentify/features/property/domain/usecases/delete_property.dart';
import 'package:rentify/features/property/domain/usecases/get_all_properties.dart';
import 'package:rentify/features/property/domain/usecases/get_properties_by_landlord.dart';
import 'property_event.dart';
import 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final AddProperty _addProperty;
  final GetAllProperties _getAllProperties;
  final GetPropertiesByLandlord _getPropertiesByLandlord;
  final DeleteProperty _deleteProperty;
  PropertyBloc({
    required AddProperty addProperty,
    required GetAllProperties getAllProperties,
    required GetPropertiesByLandlord getPropertiesByLandlord,
    required DeleteProperty deleteProperty,
  }) : _addProperty = addProperty,
       _deleteProperty = deleteProperty,
       _getAllProperties = getAllProperties,
       _getPropertiesByLandlord = getPropertiesByLandlord,
       super(PropertyInitial()) {
    // Registering event handlers
    on<FetchAllPropertiesEvent>(_onFetchAllProperties);
    on<AddNewPropertyEvent>(_onAddNewProperty);
    on<FetchLandlordPropertiesEvent>(_onFetchLandlordProperties);
    on<DeletePropertyEvent>(_onDeleteProperty);
  }

  // --- Event Handler Methods (MUST be inside the class) ---
  void _onDeleteProperty(
    DeletePropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    final result = await _deleteProperty(
      DeletePropertyParams(event.propertyId),
    );
    result.fold((failure) => emit(PropertyError(failure.message)), (_) {
      emit(PropertyDeleted());
      // Property delete hone ke baad, landlord ki list ko refresh karein
      add(FetchLandlordPropertiesEvent(event.landlordId));
    });
  }

  void _onFetchAllProperties(
    FetchAllPropertiesEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    final result = await _getAllProperties(NoParams());
    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (properties) => emit(PropertiesLoaded(properties)),
    );
  }

  void _onAddNewProperty(
    AddNewPropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    final result = await _addProperty(
      AddPropertyParams(property: event.property, images: event.images),
    );
    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (_) => emit(PropertyAdded()),
    );
  }

  void _onFetchLandlordProperties(
    FetchLandlordPropertiesEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    final result = await _getPropertiesByLandlord(
      GetPropertiesByLandlordParams(event.landlordId),
    );
    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (properties) => emit(PropertiesLoaded(properties)),
    );
  }
}
