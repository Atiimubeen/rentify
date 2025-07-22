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

import 'package:rentify/injection_container.dart' as di;

class MyBookingsPage extends StatefulWidget {
  final UserEntity tenant;
  const MyBookingsPage({super.key, required this.tenant});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(
      FetchBookingRequestsForLandlordEvent(widget.tenant.uid),
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
              title: Text('Chat with Landlord'),
            ),
          ),
        if (booking.status == BookingStatus.pending)
          const PopupMenuItem<String>(
            value: 'cancel_request',
            child: ListTile(
              leading: Icon(Icons.cancel_outlined, color: Colors.red),
              title: Text(
                'Cancel Request',
                style: TextStyle(color: Colors.red),
              ),
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
              currentUserId: widget.tenant.uid,
            ),
          ),
        );
      } else if (value == 'chat') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => di.sl<ChatBloc>(),
              child: ChatPage(
                currentUserId: widget.tenant.uid,
                otherUserId: booking.landlordId,
                booking: booking,
              ),
            ),
          ),
        );
      } else if (value == 'cancel_request') {
        context.read<BookingBloc>().add(
          TenantCancelBookingEvent(
            bookingId: booking.id,
            tenantId: widget.tenant.uid,
          ),
        );
      } else if (value == 'clear_history') {
        context.read<BookingBloc>().add(
          DeleteBookingEvent(
            bookingId: booking.id,
            currentUserId: widget.tenant.uid,
            userRole: 'tenant',
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingCancelled || state is BookingDeleted) {
            final message = state is BookingCancelled
                ? 'Booking Cancelled!'
                : 'Booking Cleared!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.orange),
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
                  FetchBookingRequestsForTenantEvent(widget.tenant.uid),
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
                    child: _buildBookingCard(booking),
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
            Icons.bookmark_remove_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No Bookings Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your requested and accepted bookings will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingEntity booking) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (booking.propertyImageUrl != null)
              ? Image.network(
                  booking.propertyImageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.house_outlined),
                ),
        ),
        title: Text(
          booking.propertyTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildStatusChip(booking.status),
        trailing: (booking.status == BookingStatus.accepted)
            ? IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) => di.sl<ChatBloc>(),
                        child: ChatPage(
                          currentUserId: widget.tenant.uid,
                          otherUserId: booking.landlordId,
                          booking: booking,
                        ),
                      ),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    String text;
    IconData icon;
    switch (status) {
      case BookingStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        icon = Icons.check_circle_outline;
        break;
      case BookingStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.highlight_off;
        break;
      case BookingStatus.cancelled:
        color = Colors.orange;
        text = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.blue;
        text = 'Pending';
        icon = Icons.hourglass_top_outlined;
    }
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.5)),
    );
  }
}
