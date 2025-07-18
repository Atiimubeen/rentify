import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.propertyId,
    required super.propertyTitle,
    required super.landlordId,
    required super.tenantId,
    required super.tenantName,
    required super.tenantPhone,
    required super.requestDate,
    required super.status,

    super.visitDate,
    super.visitTime,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      propertyId: data['propertyId'],
      propertyTitle: data['propertyTitle'] ?? '',
      landlordId: data['landlordId'],
      tenantId: data['tenantId'],
      tenantName: data['tenantName'],
      tenantPhone: data['tenantPhone'],
      requestDate: (data['requestDate'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${data['status']}',
      ),
      visitDate: data['visitDate'],
      visitTime: data['visitTime'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'propertyId': propertyId,
      'landlordId': landlordId,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'tenantPhone': tenantPhone,
      'requestDate': Timestamp.fromDate(requestDate),
      'status': status.name, // Using .name for modern enums
      'visitDate': visitDate,
      'visitTime': visitTime,
    };
  }
}
