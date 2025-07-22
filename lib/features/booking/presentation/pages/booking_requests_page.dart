import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_state.dart';
import 'package:rentify/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rentify/features/chat/presentation/pages/chat_page.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/presentation/pages/property_detail_page.dart';
import 'package:rentify/injection_container.dart'
    as di; // <<< YEH IMPORT ZAROORI HAI

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

  void _showBookingOptions(
    BuildContext context,
    BookingEntity booking,
    RelativeRect position,
  ) {
    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              leading: Icon(Icons.chat_outlined),
              title: Text('Chat with Tenant'),
            ),
          ),
        if (booking.status != BookingStatus.pending)
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
      if (value == null) return;

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
            builder: (_) => PropertyDetailPage(
              initialProperty: initialProperty,
              currentUserId: widget.landlord.uid,
            ),
          ),
        );
      } else if (value == 'chat') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => di.sl<ChatBloc>(),
              child: ChatPage(
                currentUserId: widget.landlord.uid,
                otherUserId: booking.tenantId,
                booking: booking,
              ),
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
          if (state is BookingError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is BookingRequestsLoaded) {
            if (state.bookings.isEmpty) {
              return _buildEmptyState();
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
                    child: _buildRequestCard(booking),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Booking Requests',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'New requests from tenants will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BookingEntity booking) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.propertyTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Request from: ${booking.tenantName},',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Date: ${booking.requestDate.toLocal().toString().substring(0, 10)}',
                ),
              ],
            ),
            const Divider(height: 24),
            _buildStatusSection(context, booking),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, BookingEntity booking) {
    if (booking.status == BookingStatus.pending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
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
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
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
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusChip(booking.status),
          if (booking.status == BookingStatus.accepted)
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
                    builder: (_) => BlocProvider(
                      create: (context) => di.sl<ChatBloc>(),
                      child: ChatPage(
                        currentUserId: widget.landlord.uid,
                        otherUserId: booking.tenantId,
                        booking: booking,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      );
    }
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    switch (status) {
      case BookingStatus.accepted:
        color = Colors.green;
        text = 'ACCEPTED';
        break;
      case BookingStatus.rejected:
        color = Colors.red;
        text = 'REJECTED';
        break;
      case BookingStatus.cancelled:
        color = Colors.orange;
        text = 'CANCELLED';
        break;
      default:
        color = Colors.grey;
        text = 'PENDING';
    }
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
