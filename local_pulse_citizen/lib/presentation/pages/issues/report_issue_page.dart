import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/injection_container.dart' as di;
import '../../../domain/entities/geo_location.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_picker_widget.dart';
import 'select_location_page.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubcategory;
  String _priority = 'medium';
  GeoLocation? _selectedLocation;
  List<File> _selectedImages = [];

  // Issue categories and subcategories
  final Map<String, List<String>> _categories = {
    AppConstants.dailyLifeCategory: [
      'Potholes',
      'Sewerage Issues',
      'Street Lighting',
      'Waste Management',
      'Water Supply',
      'Road Maintenance',
      'Traffic Signals',
      'Public Transport',
    ],
    AppConstants.emergencyCategory: [
      'Road Accident',
      'Fire Emergency',
      'Medical Emergency',
      'Natural Disaster',
      'Crime Incident',
      'Infrastructure Collapse',
    ],
    AppConstants.generalCategory: [
      'Public Facilities',
      'Parks & Recreation',
      'Noise Pollution',
      'Air Pollution',
      'Illegal Construction',
      'Public Safety',
      'Other',
    ],
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        _showError('Please select a category');
        return;
      }
      if (_selectedSubcategory == null) {
        _showError('Please select a subcategory');
        return;
      }
      if (_selectedLocation == null) {
        _showError('Please select a location');
        return;
      }
      if (_selectedImages.isEmpty) {
        _showError('Please add at least one image');
        return;
      }

      // Get current user from AuthBloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess) {
        _showError('Please sign in to report an issue');
        return;
      }

      // Submit the issue
      context.read<IssuesBloc>().add(
            IssueCreateRequested(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              category: _selectedCategory!,
              subcategory: _selectedSubcategory!,
              priority: _priority,
              location: _selectedLocation!,
              images: _selectedImages,
              reporterId: authState.user.id,
            ),
          );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<IssuesBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report Issue'),
          centerTitle: true,
        ),
        body: BlocListener<IssuesBloc, IssuesState>(
          listener: (context, state) {
            if (state is IssuesFailure) {
              _showError(state.message);
            } else if (state is IssueCreateSuccess) {
              _showSuccess('Issue reported successfully! Tracking ID: #${state.issueId}');
              Navigator.of(context).pop();
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              // Header
              Text(
                'Help improve your community',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Report civic issues and track their resolution',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Category Selection
              _buildCategorySelector(),
              const SizedBox(height: 16),

              // Subcategory Selection
              if (_selectedCategory != null) ...[
                _buildSubcategorySelector(),
                const SizedBox(height: 16),
              ],

              // Priority Selection
              _buildPrioritySelector(),
              const SizedBox(height: 16),

              // Title Field
              CustomTextField(
                controller: _titleController,
                label: 'Issue Title',
                hint: 'Brief description of the issue',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  if (value.trim().length > 100) {
                    return 'Title must be less than 100 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              CustomTextField(
                controller: _descriptionController,
                label: 'Detailed Description',
                hint: 'Provide more details about the issue',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  if (value.trim().length > 1000) {
                    return 'Description must be less than 1000 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Selection
              _buildLocationSelector(),
              const SizedBox(height: 16),

              // Image Selection
              ImagePickerWidget(
                images: _selectedImages,
                onImagesChanged: (images) {
                  setState(() {
                    _selectedImages = images;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              BlocBuilder<IssuesBloc, IssuesState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: state is IssuesLoading ? null : _submitReport,
                    text: 'Submit Report',
                    icon: Icons.send,
                    isLoading: state is IssuesLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.keys.map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(_getCategoryDisplayName(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                      _selectedSubcategory = null; // Reset subcategory
                    });
                  },
                  avatar: Icon(_getCategoryIcon(category)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategorySelector() {
    final subcategories = _categories[_selectedCategory!]!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subcategory',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subcategories.map((subcategory) {
                final isSelected = _selectedSubcategory == subcategory;
                return FilterChip(
                  label: Text(subcategory),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSubcategory = selected ? subcategory : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority Level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Low'),
                    value: 'low',
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Medium'),
                    value: 'medium',
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('High'),
                    value: 'high',
                    groupValue: _priority,
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Card(
      child: InkWell(
        onTap: () async {
          final location = await Navigator.of(context).push<GeoLocation>(
            MaterialPageRoute(
              builder: (context) => const SelectLocationPage(),
            ),
          );
          if (location != null) {
            setState(() {
              _selectedLocation = location;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedLocation?.address ?? 'Tap to select location',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedLocation != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case AppConstants.dailyLifeCategory:
        return 'Daily Life';
      case AppConstants.emergencyCategory:
        return 'Emergency';
      case AppConstants.generalCategory:
        return 'General';
      default:
        return category;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case AppConstants.dailyLifeCategory:
        return Icons.home_repair_service;
      case AppConstants.emergencyCategory:
        return Icons.emergency;
      case AppConstants.generalCategory:
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}