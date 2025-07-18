import 'package:equatable/equatable.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

// Jab landlord ke liye booking requests load ho jayein
class BookingRequestsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingRequestsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

// Jab tenant ki request successfully send ho jaye
class BookingRequestSent extends BookingState {}

// Jab landlord status update kar de
class BookingStatusUpdated extends BookingState {}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}
