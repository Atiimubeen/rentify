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
      FetchBookingRequestsForTenantEvent(widget.tenant.uid),
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
            builder: (_) =>
                PropertyDetailPage(initialProperty: initialProperty),
          ),
        );
      } else if (value == 'chat') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatPage(
              currentUserId: widget.tenant.uid,
              otherUserId: booking.landlordId,
              booking: booking,
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
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingRequestsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(child: Text('You have no bookings yet.'));
            }
            return ListView.builder(
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
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        booking.propertyTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Status: ${booking.status.name.toUpperCase()}',
                      ),
                      trailing: _getTrailingIcon(booking),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Loading your bookings..."));
        },
      ),
    );
  }

  Widget _getTrailingIcon(BookingEntity booking) {
    switch (booking.status) {
      case BookingStatus.accepted:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red);
      case BookingStatus.pending:
        return const Icon(Icons.hourglass_top, color: Colors.orange);
      default:
        return const SizedBox.shrink();
    }
  }
}
