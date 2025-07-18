import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class RequestBooking implements UseCase<void, RequestBookingParams> {
  final BookingRepository repository;

  RequestBooking(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestBookingParams params) async {
    return await repository.requestBooking(params.booking);
  }
}

class RequestBookingParams extends Equatable {
  final BookingEntity booking;

  const RequestBookingParams({required this.booking});

  @override
  List<Object> get props => [booking];
}
