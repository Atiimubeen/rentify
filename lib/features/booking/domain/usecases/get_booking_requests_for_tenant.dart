import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:rentify/core/error/failure.dart';
import 'package:rentify/core/usecase/usecase.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/domain/repositories/booking_repository.dart';

class GetBookingRequestsForTenant
    implements UseCase<List<BookingEntity>, TenantBookingParams> {
  final BookingRepository repository;

  GetBookingRequestsForTenant(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(
    TenantBookingParams params,
  ) async {
    return await repository.getBookingRequestsForTenant(params.tenantId);
  }
}

class TenantBookingParams extends Equatable {
  final String tenantId;

  const TenantBookingParams(this.tenantId);

  @override
  List<Object> get props => [tenantId];
}
