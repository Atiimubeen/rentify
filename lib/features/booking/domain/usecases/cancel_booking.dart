import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class CancelBooking implements UseCase<void, CancelBookingParams> {
  final BookingRepository repository;

  CancelBooking(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelBookingParams params) async {
    return await repository.cancelBooking(params.bookingId);
  }
}

class CancelBookingParams extends Equatable {
  final String bookingId;

  const CancelBookingParams(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
