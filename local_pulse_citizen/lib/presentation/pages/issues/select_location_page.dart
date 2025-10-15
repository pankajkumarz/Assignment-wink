import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../domain/entities/geo_location.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import 'map_location_picker.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({super.key});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  GeoLocation? _selectedLocation;
  bool _isLoadingCurrentLocation = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        centerTitle: true,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedLocation);
              },
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    // TODO: Implement location search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location search coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),

          // Current Location Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              onPressed: _isLoadingCurrentLocation ? null : _getCurrentLocation,
              text: 'Use Current Location',
              icon: Icons.my_location,
              isLoading: _isLoadingCurrentLocation,
            ),
          ),

          const SizedBox(height: 16),

          // Map Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              onPressed: () async {
                final location = await Navigator.of(context).push<GeoLocation>(
                  MaterialPageRoute(
                    builder: (context) => MapLocationPicker(
                      initialLocation: _selectedLocation,
                    ),
                  ),
                );
                if (location != null) {
                  setState(() {
                    _selectedLocation = location;
                  });
                }
              },
              text: 'Select on Map',
              icon: Icons.map,
              variant: ButtonVariant.secondary,
            ),
          ),

          const SizedBox(height: 16),

          // Map Preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location Preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Select on Map" to choose precise location',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Selected Location',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedLocation!.address,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Confirm Button
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                onPressed: () {
                  Navigator.of(context).pop(_selectedLocation);
                },
                text: 'Confirm Location',
                icon: Icons.check,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied');
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          final String address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((element) => element != null && element.isNotEmpty).join(', ');

          setState(() {
            _selectedLocation = GeoLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              address: address.isNotEmpty ? address : 'Unknown Address',
              city: place.locality ?? 'Unknown City',
            );
          });
        } else {
          setState(() {
            _selectedLocation = GeoLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              address: 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
              city: 'Unknown City',
            );
          });
        }
      } catch (e) {
        // If geocoding fails, still use the coordinates
        setState(() {
          _selectedLocation = GeoLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            address: 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}',
            city: 'Unknown City',
          );
        });
      }
    } catch (e) {
      _showError('Failed to get current location: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
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
}