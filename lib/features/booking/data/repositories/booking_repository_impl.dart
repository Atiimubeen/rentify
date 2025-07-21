import 'package:dartz/dartz.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/network/network_info.dart';
import 'package:rentify/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:rentify/features/booking/data/models/booking_model.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BookingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> requestBooking(BookingEntity booking) async {
    if (await networkInfo.isConnected) {
      try {
        final bookingModel = BookingModel(
          id: booking.id,
          propertyId: booking.propertyId,
          propertyTitle: booking.propertyTitle,
          landlordId: booking.landlordId,
          tenantId: booking.tenantId,
          tenantName: booking.tenantName,
          tenantPhone: booking.tenantPhone,
          requestDate: booking.requestDate,
          status: booking.status,
          visitDate: booking.visitDate,
          visitTime: booking.visitTime,
        );
        await remoteDataSource.requestBooking(bookingModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookingRequestsForLandlord(
    String landlordId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final bookings = await remoteDataSource.getBookingRequestsForLandlord(
          landlordId,
        );
        return Right(bookings);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateBookingStatus(bookingId, newStatus);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  // --- YEH METHOD AB MUKAMMAL HAI ---
  @override
  Future<Either<Failure, List<BookingEntity>>> getBookingRequestsForTenant(
    String tenantId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final bookings = await remoteDataSource.getBookingRequestsForTenant(
          tenantId,
        );
        return Right(bookings);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelBooking(bookingId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBookingFromHistory(
    String bookingId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteBookingFromHistory(bookingId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ServerFailure('No internet connection.'));
    }
  }
}
