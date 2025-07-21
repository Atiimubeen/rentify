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

// Tenant ke liye: Apni requests fetch karna
class FetchBookingRequestsForTenantEvent extends BookingEvent {
  final String tenantId;
  const FetchBookingRequestsForTenantEvent(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}

// Landlord ke liye: Status update karna
class UpdateBookingStatusEvent extends BookingEvent {
  final String bookingId;
  final String landlordId; // Needed to refetch the list for the landlord
  final BookingStatus newStatus;
  final String propertyId;

  const UpdateBookingStatusEvent({
    required this.bookingId,
    required this.newStatus,
    required this.landlordId,
    required this.propertyId,
  });

  @override
  List<Object> get props => [bookingId, newStatus, landlordId, propertyId]; // <<< YAHAN 'propertyId' ADD HUA HAI
}

// Landlord ke liye: Deal cancel karna
class CancelBookingEvent extends BookingEvent {
  final BookingEntity booking;

  const CancelBookingEvent(this.booking);

  @override
  List<Object> get props => [booking];
}

// Tenant ke liye: Apni booking cancel karna
class TenantCancelBookingEvent extends BookingEvent {
  final String bookingId;
  final String tenantId; // List refresh karne ke liye

  const TenantCancelBookingEvent({
    required this.bookingId,
    required this.tenantId,
  });

  @override
  List<Object> get props => [bookingId, tenantId];
}

class DeleteBookingEvent extends BookingEvent {
  final String bookingId;
  final String currentUserId; // List refresh karne ke liye
  final String
  userRole; // Pata lagane ke liye ke landlord ki list refresh karni hai ya tenant ki

  const DeleteBookingEvent({
    required this.bookingId,
    required this.currentUserId,
    required this.userRole,
  });

  @override
  List<Object> get props => [bookingId, currentUserId, userRole];
}
