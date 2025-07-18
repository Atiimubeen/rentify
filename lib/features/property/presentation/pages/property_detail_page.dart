import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_state.dart';

import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_state.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:uuid/uuid.dart';

class PropertyDetailPage extends StatelessWidget {
  final PropertyEntity property;
  const PropertyDetailPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Images Carousel (Simple version)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: property.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    property.imageUrls[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.address,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rent: \$${property.rent.toStringAsFixed(0)} / month',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingRequestSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking request sent successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ElevatedButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  final booking = BookingEntity(
                    id: const Uuid().v4(),
                    propertyId: property.id,
                    landlordId: property.landlordId,
                    tenantId: authState.user.uid,
                    tenantName: authState.user.name ?? 'N/A',
                    tenantPhone:
                        'N/A', // You'll get this from user profile later
                    requestDate: DateTime.now(),
                    status: BookingStatus.pending,
                  );
                  context.read<BookingBloc>().add(
                    SendBookingRequestEvent(booking),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Request to Book'),
            );
          },
        ),
      ),
    );
  }
}
