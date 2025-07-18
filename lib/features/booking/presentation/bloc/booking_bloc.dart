import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/booking/domain/usecases/get_booking_requests_for_landlord.dart';
import 'package:rentify/features/booking/domain/usecases/request_booking.dart';
import 'package:rentify/features/booking/domain/usecases/update_booking_status.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final RequestBooking _requestBooking;
  final GetBookingRequestsForLandlord _getBookingRequestsForLandlord;
  final UpdateBookingStatus _updateBookingStatus;

  BookingBloc({
    required RequestBooking requestBooking,
    required GetBookingRequestsForLandlord getBookingRequestsForLandlord,
    required UpdateBookingStatus updateBookingStatus,
  }) : _requestBooking = requestBooking,
       _getBookingRequestsForLandlord = getBookingRequestsForLandlord,
       _updateBookingStatus = updateBookingStatus,
       super(BookingInitial()) {
    on<SendBookingRequestEvent>(_onSendBookingRequest);
    on<FetchBookingRequestsForLandlordEvent>(
      _onFetchBookingRequestsForLandlord,
    );
    on<UpdateBookingStatusEvent>(_onUpdateBookingStatus);
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
    // We don't show a loading indicator here to make the UI smoother
    final result = await _updateBookingStatus(
      UpdateBookingStatusParams(
        bookingId: event.bookingId,
        newStatus: event.newStatus,
      ),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (_) => emit(BookingStatusUpdated()),
    );
  }
}
