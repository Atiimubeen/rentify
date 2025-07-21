import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_event.dart';

import 'package:rentify/features/booking/presentation/pages/booking_requests_page.dart';
import 'package:rentify/features/profile/presentation/pages/profile_page.dart';

import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentify/features/property/presentation/bloc/property_event.dart';
import 'package:rentify/features/property/presentation/bloc/property_state.dart';
import 'package:rentify/features/property/presentation/pages/add_property_page.dart';

class LandlordDashboardPage extends StatefulWidget {
  final UserEntity user;
  const LandlordDashboardPage({super.key, required this.user});

  @override
  State<LandlordDashboardPage> createState() => _LandlordDashboardPageState();
}

class _LandlordDashboardPageState extends State<LandlordDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(
      FetchLandlordPropertiesEvent(widget.user.uid),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this property? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<PropertyBloc>().add(
                  DeletePropertyEvent(
                    propertyId: propertyId,
                    landlordId: widget.user.uid,
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hello, ${widget.user.name?.split(' ').first ?? ''}! 👋',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfilePage(user: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            tooltip: 'Booking Requests',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookingRequestsPage(landlord: widget.user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyAdded || state is PropertyDeleted) {
            final message = state is PropertyAdded
                ? 'Property Added Successfully!'
                : 'Property Deleted Successfully!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green),
            );
          } else if (state is PropertyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PropertyError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is PropertiesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PropertyBloc>().add(
                  FetchLandlordPropertiesEvent(widget.user.uid),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: _buildSummaryCard(state.properties.length),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "Your Properties",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.properties.isEmpty
                        ? _buildEmptyState()
                        : AnimationLimiter(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              itemCount: state.properties.length,
                              itemBuilder: (context, index) {
                                final property = state.properties[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 400),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _buildPropertyCard(property),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddPropertyPage(landlordId: widget.user.uid),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add New Property',
      ),
    );
  }

  Widget _buildSummaryCard(int propertyCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.home_work_outlined, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyCount.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Total Properties Listed',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.house_siding, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Properties Listed',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first property.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(PropertyEntity property) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: property.imageUrls.isNotEmpty
                ? Image.network(property.imageUrls.first, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.house,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              property.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Rent: Rs. ${property.rent.toStringAsFixed(0)}/month',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: property.isAvailable
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    property.isAvailable ? 'Available' : 'Booked',
                    style: TextStyle(
                      color: property.isAvailable
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, property.id);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
