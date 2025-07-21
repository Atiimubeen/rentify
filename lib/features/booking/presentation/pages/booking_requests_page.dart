import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';

import 'package:rentify/features/booking/presentation/bloc/booking_state.dart';
import 'package:rentify/features/chat/presentation/pages/chat_page.dart';

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

  // --- YEH METHOD AB showMenu ISTEMAL KARTA HAI ---
  void _showBookingOptions(
    BuildContext context,
    BookingEntity booking,
    RelativeRect position,
  ) {
    showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'view_details',
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('View Property Details'),
          ),
        ),
        if (booking.status == BookingStatus.accepted)
          const PopupMenuItem<String>(
            value: 'chat',
            child: ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat with Tenant'),
            ),
          ),
        if (booking.status == BookingStatus.rejected ||
            booking.status == BookingStatus.cancelled)
          const PopupMenuItem<String>(
            value: 'clear_history',
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
              title: Text(
                'Clear from History',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
      ],
    ).then((String? value) {
      if (value == null) return; // Agar user ne menu se bahar click kiya

      if (value == 'view_details') {
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
            builder: (_) =>
                PropertyDetailPage(initialProperty: initialProperty),
          ),
        );
      } else if (value == 'chat') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              currentUserId: widget.landlord.uid,
              otherUserId: booking.tenantId,
              booking: booking,
            ),
          ),
        );
      } else if (value == 'clear_history') {
        context.read<BookingBloc>().add(
          DeleteBookingEvent(
            bookingId: booking.id,
            currentUserId: widget.landlord.uid,
            userRole: 'landlord',
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingStatusUpdated || state is BookingDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Action successful!'),
                backgroundColor: Colors.green,
              ),
            );
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
                  return GestureDetector(
                    // <<< InkWell ki jagah GestureDetector
                    onLongPressStart: (details) {
                      final position = RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        MediaQuery.of(context).size.width -
                            details.globalPosition.dx,
                        MediaQuery.of(context).size.height -
                            details.globalPosition.dy,
                      );
                      _showBookingOptions(context, booking, position);
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
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
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Status: ${booking.status.name.toUpperCase()}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: booking.status == BookingStatus.accepted
                ? Colors.green
                : Colors.red,
          ),
        ),
      );
    }
  }
}
