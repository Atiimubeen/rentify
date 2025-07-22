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
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _sizeController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();

  List<XFile> _images = [];
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
    final availableSlots = 5 - _images.length;
    if (availableSlots <= 0) {
      // Yeh check abhi bhi zaroori hai, lekin UI behtar ho gayi hai
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already selected the maximum of 5 images.'),
        ),
      );
      return;
    }
    final pickedFiles = await _picker.pickMultiImage(
      imageQuality: 85,
      limit: availableSlots,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
      });
    }
  }

  void _submitForm() {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.')),
      );
      setState(() => _currentStep = 2);
      return;
    }

    final property = PropertyEntity(
      id: const Uuid().v4(),
      landlordId: widget.landlordId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      rent: double.tryParse(_rentController.text.trim()) ?? 0.0,
      address: _addressController.text.trim(),
      sizeSqft: double.tryParse(_sizeController.text.trim()) ?? 0.0,
      bedrooms: int.tryParse(_bedroomsController.text.trim()) ?? 0,
      bathrooms: int.tryParse(_bathroomsController.text.trim()) ?? 0,
      imageUrls: [],
      isAvailable: true,
      postedDate: DateTime.now(),
    );

    context.read<PropertyBloc>().add(
      AddNewPropertyEvent(
        property: property,
        images: _images.map((xfile) => File(xfile.path)).toList(),
        landlordId: widget.landlordId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List a New Property'), elevation: 1),
      body: BlocListener<PropertyBloc, PropertyState>(
        listener: (context, state) {
          if (state is PropertyAdded) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else if (state is PropertyError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_formKeys[_currentStep].currentState!.validate()) {
              if (_currentStep < 2) {
                setState(() => _currentStep += 1);
              } else {
                _submitForm();
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: [_buildStep1(), _buildStep2(), _buildStep3()],
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: BlocBuilder<PropertyBloc, PropertyState>(
                builder: (context, state) {
                  if (state is PropertyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Row(
                    children: [
                      if (_currentStep == 2)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_home_work),
                            onPressed: details.onStepContinue,
                            label: const Text('SUBMIT'),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('NEXT'),
                        ),
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('BACK'),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Details'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Property Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Full Address',
              icon: Icons.location_city,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Specs'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            _buildTextField(
              controller: _rentController,
              label: 'Rent per month (Rs.)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _sizeController,
                    label: 'Size (sqft)',
                    icon: Icons.square_foot,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _bedroomsController,
                    label: 'Beds',
                    icon: Icons.bed,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _bathroomsController,
                    label: 'Baths',
                    icon: Icons.bathtub,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Photos'),
      isActive: _currentStep >= 2,
      content: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            _buildImagePreview(),
            const SizedBox(height: 16),
            // --- YEH LOGIC AB BEHTAR HAI ---
            // Button sirf tab dikhao jab 5 se kam images hon
            if (_images.length < 5)
              OutlinedButton.icon(
                icon: const Icon(Icons.add_a_photo),
                onPressed: _pickImages,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                label: Text(_images.isEmpty ? 'Add Photos' : 'Add More Photos'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return GestureDetector(
        onTap: _pickImages,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 50,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              const Text('Tap to add photos'),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Images (${_images.length}/5)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_images[index].path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
