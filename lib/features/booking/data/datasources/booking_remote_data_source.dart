import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/booking/data/models/booking_model.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRemoteDataSource {
  Future<void> requestBooking(BookingModel booking);
  Future<List<BookingModel>> getBookingRequestsForLandlord(String landlordId);
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus);
  Future<List<BookingModel>> getBookingRequestsForTenant(String tenantId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});
  Future<List<BookingModel>> getBookingRequestsForTenant(
    String tenantId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('bookings')
          .where('tenantId', isEqualTo: tenantId)
          .orderBy('requestDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch your bookings.');
    }
  }

  @override
  Future<void> requestBooking(BookingModel booking) async {
    try {
      await firestore.collection('bookings').add(booking.toFirestore());
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to send booking request.');
    }
  }

  @override
  Future<List<BookingModel>> getBookingRequestsForLandlord(
    String landlordId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('bookings')
          .where('landlordId', isEqualTo: landlordId)
          .orderBy('requestDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => BookingModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch booking requests.');
    }
  }

  @override
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    try {
      await firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus.name,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update booking status.');
    }
  }
}
