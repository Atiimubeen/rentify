import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  // Tenant ke liye: Nai booking request bhejna
  Future<Either<Failure, void>> requestBooking(BookingEntity booking);

  // Landlord ke liye: Apni properties par anay wali saari requests dekhna
  Future<Either<Failure, List<BookingEntity>>> getBookingRequestsForLandlord(
    String landlordId,
  );

  // Tenant ke liye: Apni bheji hui saari requests dekhna
  Future<Either<Failure, List<BookingEntity>>> getBookingRequestsForTenant(
    String tenantId,
  );

  // Landlord ke liye: Booking request ka status update karna (Accept/Reject)
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  );

  Future<Either<Failure, void>> cancelBooking(String bookingId);
}
