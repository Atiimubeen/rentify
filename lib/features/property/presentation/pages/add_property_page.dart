import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentify/features/property/domain/entities/property_entity.dart';
import 'package:rentify/features/property/presentation/bloc/property_bloc.dart';
import 'package:rentify/features/property/presentation/bloc/property_event.dart';
import 'package:rentify/features/property/presentation/bloc/property_state.dart';
import 'package:uuid/uuid.dart';

class AddPropertyPage extends StatefulWidget {
  final String landlordId;
  const AddPropertyPage({super.key, required this.landlordId});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rentController = TextEditingController();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();

  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rentController.dispose();
    _addressController.dispose();
    _sizeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    // Allow picking up to 5 images
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select a maximum of 5 images.')),
      );
      return;
    }

    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: 5 - _images.length,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one image.')),
        );
        return;
      }

      final property = PropertyEntity(
        id: const Uuid().v4(), // Generate a temporary unique ID
        landlordId: widget.landlordId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        rent: double.tryParse(_rentController.text.trim()) ?? 0.0,
        address: _addressController.text.trim(),
        sizeSqft: double.tryParse(_sizeController.text.trim()) ?? 0.0,
        bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 0,
        bathrooms: int.tryParse(_bathroomsController.text.trim()) ?? 0,
        imageUrls: [], // This will be filled by the data layer after upload
        isAvailable: true,
        postedDate: DateTime.now(),
      );

      context.read<PropertyBloc>().add(
        AddNewPropertyEvent(property: property, images: _images),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Property')),
      body: BlocListener<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Property Added Successfully!')),
            );
            // Go back to the dashboard
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else if (state is PropertyError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Property Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (v) =>
                      v!.isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rentController,
                  decoration: const InputDecoration(
                    labelText: 'Rent per month (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v!.isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Full Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'This field is required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sizeController,
                        decoration: const InputDecoration(
                          labelText: 'Size (sqft)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        decoration: const InputDecoration(
                          labelText: 'Bedrooms',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        decoration: const InputDecoration(
                          labelText: 'Bathrooms',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImages,
                  label: const Text('Pick Images'),
                ),
                if (_images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${_images.length} images selected',
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                BlocBuilder<PropertyBloc, PropertyState>(
                  builder: (context, state) {
                    if (state is PropertyLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Add Property'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
