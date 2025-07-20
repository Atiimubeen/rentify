import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/booking/domain/usecases/cancel_booking.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_landlord.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_tenant.dart';
import 'package:rentify/features/booking/domain/usecases/request_booking.dart';
import 'package:rentify/features/booking/domain/usecases/update_booking_status.dart';
import 'package:rentify/features/property/domain/usecases/update_property_availability.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final RequestBooking _requestBooking;
  final GetBookingRequestsForLandlord _getBookingRequestsForLandlord;
  final GetBookingRequestsForTenant _getBookingRequestsForTenant;
  final UpdateBookingStatus _updateBookingStatus;
  final UpdatePropertyAvailability _updatePropertyAvailability;
  final CancelBooking _cancelBooking; // <<< YEH AB USECASE HAI, EVENT NAHI

  BookingBloc({
    required RequestBooking requestBooking,
    required GetBookingRequestsForLandlord getBookingRequestsForLandlord,
    required GetBookingRequestsForTenant getBookingRequestsForTenant,
    required UpdateBookingStatus updateBookingStatus,
    required UpdatePropertyAvailability updatePropertyAvailability,
    required CancelBooking
    cancelBooking, // <<< CONSTRUCTOR MEIN SAHI USECASE RECEIVE KAREIN
  }) : _requestBooking = requestBooking,
       _getBookingRequestsForLandlord = getBookingRequestsForLandlord,
       _getBookingRequestsForTenant = getBookingRequestsForTenant,
       _updateBookingStatus = updateBookingStatus,
       _updatePropertyAvailability = updatePropertyAvailability,
       _cancelBooking = cancelBooking, // <<< SAHI USECASE KO INITIALIZE KAREIN
       super(BookingInitial()) {
    on<SendBookingRequestEvent>(_onSendBookingRequest);
    on<FetchBookingRequestsForLandlordEvent>(
      _onFetchBookingRequestsForLandlord,
    );
    on<FetchBookingRequestsForTenantEvent>(_onFetchBookingRequestsForTenant);
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
    on<TenantCancelBookingEvent>(_onTenantCancelBooking);
  }

  void _onSendBookingRequest(
    SendBookingRequestEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await _requestBooking(
      RequestBookingParams(booking: event.booking),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (_) => emit(BookingRequestSent()),
    );
  }

  void _onFetchBookingRequestsForLandlord(
    FetchBookingRequestsForLandlordEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await _getBookingRequestsForLandlord(
      LandlordBookingParams(event.landlordId),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingRequestsLoaded(bookings)),
    );
  }

  void _onFetchBookingRequestsForTenant(
    FetchBookingRequestsForTenantEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await _getBookingRequestsForTenant(
      TenantBookingParams(event.tenantId),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingRequestsLoaded(bookings)),
    );
  }

  void _onUpdateBookingStatus(
    UpdateBookingStatusEvent event,
    Emitter<BookingState> emit,
  ) async {
    final result = await _updateBookingStatus(
      UpdateBookingStatusParams(
        bookingId: event.bookingId,
        newStatus: event.newStatus,
      ),
    );

    await result.fold((failure) async => emit(BookingError(failure.message)), (
      _,
    ) async {
      if (event.newStatus == BookingStatus.accepted) {
        await _updatePropertyAvailability(
          UpdatePropertyAvailabilityParams(
            propertyId: event.propertyId,
            isAvailable: false,
          ),
        );
      }
      emit(BookingStatusUpdated());
      add(FetchBookingRequestsForLandlordEvent(event.landlordId));
    });
  }

  void _onTenantCancelBooking(
    TenantCancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    final result = await _cancelBooking(CancelBookingParams(event.bookingId));
    result.fold((failure) => emit(BookingError(failure.message)), (_) {
      emit(BookingCancelled());
      // Booking cancel hone ke baad, tenant ki list ko refresh karein
      add(FetchBookingRequestsForTenantEvent(event.tenantId));
    });
  }
}
