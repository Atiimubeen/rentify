import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class UpdateBookingStatus implements UseCase<void, UpdateBookingStatusParams> {
  final BookingRepository repository;

  UpdateBookingStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateBookingStatusParams params) async {
    return await repository.updateBookingStatus(
      params.bookingId,
      params.newStatus,
    );
  }
}

class UpdateBookingStatusParams extends Equatable {
  final String bookingId;
  final BookingStatus newStatus;

  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [bookingId, newStatus];
}
