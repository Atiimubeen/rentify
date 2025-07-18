import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_event.dart';
import 'package:rentify/features/profile/presentation/bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  final UserEntity user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    // Fetch the latest profile data
    context.read<ProfileBloc>().add(FetchProfileEvent(widget.user.uid));
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      context.read<ProfileBloc>().add(
        UploadPictureEvent(image: File(pickedFile.path), uid: widget.user.uid),
      );
    }
  }

  void _updateProfile() {
    final updatedUser = UserEntity(
      uid: widget.user.uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: widget.user.email, // Email cannot be changed
      role: widget.user.role, // Role cannot be changed
      photoUrl: widget.user.photoUrl,
    );
    context.read<ProfileBloc>().add(UpdateProfileEvent(updatedUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile Updated Successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          UserEntity? currentUser;
          if (state is ProfileLoaded) {
            currentUser = state.user;
            // Update controllers if the state has new data
            _nameController.text = currentUser.name ?? '';
            _phoneController.text = currentUser.phone ?? '';
          } else {
            currentUser = widget.user; // Show initial data
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: (currentUser?.photoUrl != null)
                          ? NetworkImage(currentUser!.photoUrl!)
                          : null,
                      child: (currentUser?.photoUrl == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: currentUser?.email ?? 'N/A',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
