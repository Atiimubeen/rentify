import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_event.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentify/features/property/presentation/bloc/property_event.dart';
import 'package:rentify/features/property/presentation/bloc/property_state.dart';
import 'package:rentify/features/property/presentation/pages/add_property_page.dart';
import 'package:rentify/features/property/presentation/pages/booking_requests_page.dart';

class LandlordDashboardPage extends StatelessWidget {
  final UserEntity user;
  const LandlordDashboardPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Screen khultay hi landlord ki properties fetch karein
    context.read<PropertyBloc>().add(FetchLandlordPropertiesEvent(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          // --- YEH NAYA BUTTON ADD HUA HAI ---
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Booking Requests',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingRequestsPage(landlord: user),
                ),
              );
            },
          ),
          // ------------------------------------
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          // Jab property add ho jaye to list refresh karein
          if (state is PropertyAdded) {
            context.read<PropertyBloc>().add(
              FetchLandlordPropertiesEvent(user.uid),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Property list updated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PropertyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PropertyError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is PropertiesLoaded) {
            if (state.properties.isEmpty) {
              return const Center(
                child: Text('You have not added any properties yet.'),
              );
            }
            // Yahan hum landlord ki properties list karengy
            return ListView.builder(
              itemCount: state.properties.length,
              itemBuilder: (context, index) {
                final property = state.properties[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: property.imageUrls.isNotEmpty
                        ? Image.network(
                            property.imageUrls.first,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(width: 100, color: Colors.grey[200]),
                    title: Text(property.title),
                    subtitle: Text(
                      'Rent: \$${property.rent.toStringAsFixed(0)}/month',
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Loading your properties...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // AddPropertyPage par navigate karein
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddPropertyPage(landlordId: user.uid),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Property',
      ),
    );
  }
}
