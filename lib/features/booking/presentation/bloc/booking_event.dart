import 'package:equatable/equatable.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

// Tenant ke liye: Nai request bhejna
class SendBookingRequestEvent extends BookingEvent {
  final BookingEntity booking;
  const SendBookingRequestEvent(this.booking);
}

// Landlord ke liye: Apni requests fetch karna
class FetchBookingRequestsForLandlordEvent extends BookingEvent {
  final String landlordId;
  const FetchBookingRequestsForLandlordEvent(this.landlordId);
}

// --- YEH NAYA EVENT ADD HUA HAI ---
// Tenant ke liye: Apni requests fetch karna
class FetchBookingRequestsForTenantEvent extends BookingEvent {
  final String tenantId;
  const FetchBookingRequestsForTenantEvent(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}
// ------------------------------------

// Landlord ke liye: Status update karna
class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final String landlordId; // Needed to refetch the list for the landlord
  final BookingStatus newStatus;

  const UpdateBookingStatusEvent({
    required this.bookingId,
    required this.newStatus,
    required this.landlordId,
  });

  @override
  List<Object> get props => [bookingId, newStatus, landlordId];
}
