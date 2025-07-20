import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/property/domain/usecases/add_property.dart';
import 'package:rentify/features/property/domain/usecases/delete_property.dart';
import 'package:rentify/features/property/domain/usecases/get_all_properties.dart';
import 'package:rentify/features/property/domain/usecases/get_properties_by_landlord.dart';
import 'package:rentify/features/property/domain/usecases/get_property_by_id.dart';
import 'property_event.dart';
import 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final AddProperty _addProperty;
  final GetAllProperties _getAllProperties;
  final GetPropertiesByLandlord _getPropertiesByLandlord;
  final DeleteProperty _deleteProperty;
  final GetPropertyById _getPropertyById; // <<< USE CASE ADDED

  PropertyBloc({
    required AddProperty addProperty,
    required GetAllProperties getAllProperties,
    required GetPropertiesByLandlord getPropertiesByLandlord,
    required DeleteProperty deleteProperty,
    required GetPropertyById getPropertyById, // <<< ADDED TO CONSTRUCTOR
  }) : _addProperty = addProperty,
       _getAllProperties = getAllProperties,
       _getPropertiesByLandlord = getPropertiesByLandlord,
       _deleteProperty = deleteProperty,
       _getPropertyById = getPropertyById, // <<< INITIALIZED
       super(PropertyInitial()) {
    on<FetchAllPropertiesEvent>(_onFetchAllProperties);
    on<FetchLandlordPropertiesEvent>(_onFetchLandlordProperties);
    on<AddNewPropertyEvent>(_onAddNewProperty);
    on<DeletePropertyEvent>(_onDeleteProperty);
    on<FetchPropertyByIdEvent>(_onFetchPropertyById); // <<< EVENT HANDLER ADDED
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

  void _onAddNewProperty(
    AddNewPropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    final result = await _addProperty(
      AddPropertyParams(property: event.property, images: event.images),
    );
    result.fold((failure) => emit(PropertyError(failure.message)), (_) {
      emit(PropertyAdded());
      add(FetchLandlordPropertiesEvent(event.landlordId));
    });
  }

  void _onDeleteProperty(
    DeletePropertyEvent event,
    Emitter<PropertyState> emit,
  ) async {
    final result = await _deleteProperty(
      DeletePropertyParams(event.propertyId),
    );
    result.fold((failure) => emit(PropertyError(failure.message)), (_) {
      emit(PropertyDeleted());
      add(FetchLandlordPropertiesEvent(event.landlordId));
    });
  }

  // --- THIS NEW METHOD IS ADDED ---
  void _onFetchPropertyById(
    FetchPropertyByIdEvent event,
    Emitter<PropertyState> emit,
  ) async {
    emit(PropertyLoading());
    final result = await _getPropertyById(
      GetPropertyByIdParams(event.propertyId),
    );
    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (property) => emit(PropertyDetailLoaded(property)),
    );
  }
}
