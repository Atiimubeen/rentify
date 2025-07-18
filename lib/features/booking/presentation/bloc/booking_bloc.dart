import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_landlord.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_tenant.dart';
import 'package:rentify/features/booking/domain/usecases/request_booking.dart';
import 'package:rentify/features/booking/domain/usecases/update_booking_status.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final RequestBooking _requestBooking;
  final GetBookingRequestsForLandlord _getBookingRequestsForLandlord;
  final GetBookingRequestsForTenant
  _getBookingRequestsForTenant; // <<< USE CASE ADDED
  final UpdateBookingStatus _updateBookingStatus;

  BookingBloc({
    required RequestBooking requestBooking,
    required GetBookingRequestsForLandlord getBookingRequestsForLandlord,
    required GetBookingRequestsForTenant
    getBookingRequestsForTenant, // <<< ADDED TO CONSTRUCTOR
    required UpdateBookingStatus updateBookingStatus,
  }) : _requestBooking = requestBooking,
       _getBookingRequestsForLandlord = getBookingRequestsForLandlord,
       _getBookingRequestsForTenant =
           getBookingRequestsForTenant, // <<< INITIALIZED
       _updateBookingStatus = updateBookingStatus,
       super(BookingInitial()) {
    on<SendBookingRequestEvent>(_onSendBookingRequest);
    on<FetchBookingRequestsForLandlordEvent>(
      _onFetchBookingRequestsForLandlord,
    );
    on<FetchBookingRequestsForTenantEvent>(
      _onFetchBookingRequestsForTenant,
    ); // <<< EVENT HANDLER ADDED
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
  }

  // --- THIS METHOD IS NOW CORRECTED ---
  void _onFetchBookingRequestsForTenant(
    FetchBookingRequestsForTenantEvent event, // <<< CORRECT EVENT
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    // Use the correct use case and params
    final result = await _getBookingRequestsForTenant(
      TenantBookingParams(event.tenantId), // <<< CORRECT PARAMS
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingRequestsLoaded(bookings)),
    );
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
      emit(BookingStatusUpdated());
      // After updating, automatically refetch the landlord's list
      final newListResult = await _getBookingRequestsForLandlord(
        LandlordBookingParams(event.landlordId),
      );
      newListResult.fold(
        (failure) => emit(BookingError(failure.message)),
        (bookings) => emit(BookingRequestsLoaded(bookings)),
      );
    });
  }
}
