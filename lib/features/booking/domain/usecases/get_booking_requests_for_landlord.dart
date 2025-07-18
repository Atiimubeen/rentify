import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class GetBookingRequestsForLandlord
    implements UseCase<List<BookingEntity>, LandlordBookingParams> {
  final BookingRepository repository;

  GetBookingRequestsForLandlord(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    LandlordBookingParams params,
  ) async {
    return await repository.getBookingRequestsForLandlord(params.landlordId);
  }
}

class LandlordBookingParams extends Equatable {
  final String landlordId;

  const LandlordBookingParams(this.landlordId);

  @override
  List<Object> get props => [landlordId];
}
