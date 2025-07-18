import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_state.dart';

class BookingRequestsPage extends StatelessWidget {
  final UserEntity landlord;
  const BookingRequestsPage({super.key, required this.landlord});

  @override
  Widget build(BuildContext context) {
    context.read<BookingBloc>().add(
      FetchBookingRequestsForLandlordEvent(landlord.uid),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status Updated!'),
                backgroundColor: Colors.blue,
              ),
            );
            // Refresh the list
            context.read<BookingBloc>().add(
              FetchBookingRequestsForLandlordEvent(landlord.uid),
            );
          }
        },
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BookingRequestsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Text('You have no new booking requests.'),
              );
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request from: ${booking.tenantName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Date: ${booking.requestDate.toLocal().toString().substring(0, 10)}',
                        ),
                        const Divider(),
                        if (booking.status == BookingStatus.pending)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  context.read<BookingBloc>().add(
                                    UpdateBookingStatusEvent(
                                      bookingId: booking.id,
                                      newStatus: BookingStatus.rejected,
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<BookingBloc>().add(
                                    UpdateBookingStatusEvent(
                                      bookingId: booking.id,
                                      newStatus: BookingStatus.accepted,
                                    ),
                                  );
                                },
                                child: const Text('Accept'),
                              ),
                            ],
                          )
                        else
                          Text(
                            'Status: ${booking.status.name.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Loading booking requests...'));
        },
      ),
    );
  }
}
