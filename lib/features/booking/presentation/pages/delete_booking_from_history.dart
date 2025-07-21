import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class DeleteBookingFromHistory
    implements UseCase<void, DeleteBookingFromHistoryParams> {
  final BookingRepository repository;

  DeleteBookingFromHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(
    DeleteBookingFromHistoryParams params,
  ) async {
    return await repository.deleteBookingFromHistory(params.bookingId);
  }
}

class DeleteBookingFromHistoryParams extends Equatable {
  final String bookingId;

  const DeleteBookingFromHistoryParams(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
