import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/city_selector.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  
  String? _selectedCity;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _ageController = TextEditingController(text: widget.user.age.toString());
    _selectedCity = widget.user.city;

    // Listen for changes
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onCityChanged(String city) {
    setState(() {
      _selectedCity = city;
      _hasChanges = true;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final age = int.tryParse(_ageController.text);
      if (age == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid age'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedUser = widget.user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        age: age,
        city: _selectedCity!,
        updatedAt: DateTime.now(),
      );

      // TODO: Implement profile update through BLoC
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : 'U',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            // TODO: Implement image picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile picture update coming soon'),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field (Read-only)
              CustomTextField(
                controller: TextEditingController(text: widget.user.email),
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                enabled: false,
              ),
              const SizedBox(height: 8),
              Text(
                'Email cannot be changed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),

              // Age and Phone Row
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _ageController,
                      label: 'Age',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.cake_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 13 || age > 120) {
                          return 'Invalid age';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Phone (Optional)',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^\+?[\d\s\-\(\)]{10,15}$')
                              .hasMatch(value)) {
                            return 'Invalid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // City Selector
              CitySelector(
                selectedCity: _selectedCity,
                onCitySelected: _onCityChanged,
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                onPressed: _hasChanges ? _saveProfile : null,
                text: 'Save Changes',
                icon: Icons.save,
              ),
              const SizedBox(height: 16),

              // Cancel Button
              CustomButton(
                onPressed: () => Navigator.of(context).pop(),
                text: 'Cancel',
                variant: ButtonVariant.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}