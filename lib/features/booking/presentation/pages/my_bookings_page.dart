import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/booking/domain/entities/booking_entity.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_event.dart';
import 'package:rentify/features/booking/presentation/bloc/booking_state.dart';
import 'package:rentify/features/chat/presentation/pages/chat_page.dart';

// 1. Isay StatefulWidget banayein
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
    // 2. Event ko initState ke andar call karein
    context.read<BookingBloc>().add(
      FetchBookingRequestsForTenantEvent(widget.tenant.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingError) {
            return Center(child: Text(state.message));
          }
          if (state is BookingRequestsLoaded) {
            if (state.bookings.isEmpty) {
              return const Center(child: Text('You have no bookings yet.'));
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      booking.propertyTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: ${booking.status.name.toUpperCase()}',
                    ),
                    trailing: _buildTrailingWidget(context, booking),
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

  // Helper function to build the trailing widget
  Widget? _buildTrailingWidget(BuildContext context, BookingEntity booking) {
    if (booking.status == BookingStatus.accepted) {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatPage(
                currentUserId: widget.tenant.uid,
                otherUserId: booking.landlordId,
              ),
            ),
          );
        },
        child: const Text('Chat'),
      );
    } else if (booking.status == BookingStatus.rejected) {
      return const Icon(Icons.cancel, color: Colors.red);
    }
    // For pending status, show nothing special
    return null;
  }
}
