import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_bloc.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_event.dart';
import 'package:rentify/features/auth/presenatation/bloc/auth_state.dart';

import 'package:rentify/features/booking/presentation/pages/my_bookings_page.dart';
import 'package:rentify/features/profile/presentation/pages/profile_page.dart';

import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentify/features/property/presentation/bloc/property_event.dart';
import 'package:rentify/features/property/presentation/bloc/property_state.dart';
import 'package:rentify/features/property/presentation/pages/property_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(FetchAllPropertiesEvent());
  }

  @override
  Widget build(BuildContext context) {
    // AuthBloc se user ka naam haasil karein
    final user = (context.read<AuthBloc>().state as Authenticated).user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hello, ${user.name?.split(' ').first ?? ''}! 👋',
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
                MaterialPageRoute(builder: (_) => ProfilePage(user: user)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            tooltip: 'My Bookings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MyBookingsPage(tenant: user)),
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
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          if (state is PropertyError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is PropertiesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PropertyBloc>().add(FetchAllPropertiesEvent());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      "Find Your Next Home",
                      style: TextStyle(
                        fontSize: 24,
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
                                      child: _buildPropertyCard(
                                        context,
                                        property,
                                      ),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apartment_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Properties Available',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later for new listings.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyEntity property) {
    final formatter = NumberFormat.currency(
      locale: 'en_PK',
      symbol: 'Rs. ',
      decimalDigits: 0,
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PropertyDetailPage(initialProperty: property),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatter.format(property.rent),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        '${property.bedrooms} Beds | ${property.bathrooms} Baths',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
