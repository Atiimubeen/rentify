import 'package:equatable/equatable.dart';

enum BookingStatus { pending, accepted, rejected, cancelled }

class BookingEntity extends Equatable {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String landlordId;
  final String tenantId;
  final String tenantName; // To show on landlord's dashboard
  final String tenantPhone; // To show on landlord's dashboard
  final DateTime requestDate;
  final BookingStatus status;
  final String? visitDate; // Optional: Can be for a visit or direct booking
  final String? visitTime; // Optional

  const BookingEntity({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.landlordId,
    required this.tenantId,
    required this.tenantName,
    required this.tenantPhone,
    required this.requestDate,
    required this.status,
    this.visitDate,
    this.visitTime,
  });

  @override
  List<Object?> get props => [
    id,
    propertyId,
    propertyTitle, // <<< YEH LINE MISSING THI
    landlordId,
    tenantId,
    tenantName,
    tenantPhone,
    requestDate,
    status,
    visitDate,
    visitTime,
  ];
}
