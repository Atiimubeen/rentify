import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_state.dart';
import 'package:rentify/features/chat/presentation/pages/chat_page.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/presentation/pages/property_detail_page.dart';

class BookingRequestsPage extends StatefulWidget {
  final UserEntity landlord;
  const BookingRequestsPage({super.key, required this.landlord});

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(
      FetchBookingRequestsForLandlordEvent(widget.landlord.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status Updated! Refreshing list...'),
                backgroundColor: Colors.blue,
              ),
            );
            // BLoC ab khud hi list refresh kar raha hai
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
          if (state is BookingError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BookingRequestsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Text('You have no new booking requests.'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookingBloc>().add(
                  FetchBookingRequestsForLandlordEvent(widget.landlord.uid),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    child: InkWell(
                      onTap: () {
                        final initialProperty = PropertyEntity(
                          id: booking.propertyId,
                          title: booking.propertyTitle,
                          landlordId: booking.landlordId,
                          isAvailable: false,
                          description: '',
                          rent: 0,
                          address: '',
                          sizeSqft: 0,
                          bedrooms: 0,
                          bathrooms: 0,
                          imageUrls: [],
                          postedDate: DateTime.now(),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailPage(
                              initialProperty: initialProperty,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request for: ${booking.propertyTitle}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('From: ${booking.tenantName}'),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${booking.requestDate.toLocal().toString().substring(0, 10)}',
                            ),
                            const Divider(height: 20),
                            _buildStatusSection(context, booking),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, BookingEntity booking) {
    if (booking.status == BookingStatus.pending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              context.read<BookingBloc>().add(
                UpdateBookingStatusEvent(
                  bookingId: booking.id,
                  newStatus: BookingStatus.rejected,
                  landlordId: widget.landlord.uid,
                  propertyId: booking.propertyId,
                ),
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              context.read<BookingBloc>().add(
                UpdateBookingStatusEvent(
                  bookingId: booking.id,
                  newStatus: BookingStatus.accepted,
                  landlordId: widget.landlord.uid,
                  propertyId: booking.propertyId,
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      );
    } else if (booking.status == BookingStatus.accepted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Status: ACCEPTED',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    currentUserId: widget.landlord.uid,
                    otherUserId: booking.tenantId,
                    booking: booking,
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else {
      // Cancelled or Rejected
      final statusText = booking.status.name.toUpperCase();
      return Text(
        'Status: $statusText',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      );
    }
  }
}
