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
    // Controllers ko initial user data se set karein
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    // Hamesha latest profile data fetch karein
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
      // Yeh fields change nahi ho saktin
      email: widget.user.email,
      role: widget.user.role,
      photoUrl: widget.user.photoUrl,
    );
    context.read<ProfileBloc>().add(UpdateProfileEvent(updatedUser));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
            // State se anay walay naye data ke saath controllers ko update karein
            if (_nameController.text != currentUser.name) {
              _nameController.text = currentUser.name ?? '';
            }
            if (_phoneController.text != currentUser.phone) {
              _phoneController.text = currentUser.phone ?? '';
            }
          } else {
            // Agar state loaded nahi, to initial data dikhayein
            currentUser = widget.user;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: (currentUser?.photoUrl != null)
                          ? NetworkImage(currentUser!.photoUrl!)
                          : null,
                      child: (currentUser?.photoUrl == null)
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade600,
                            )
                          : null,
                    ),
                    Material(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  readOnly: true,
                  initialValue: currentUser?.email ?? 'N/A',
                  label: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
      ),
    );
  }
}
