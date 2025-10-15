import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../../domain/entities/geo_location.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({
    super.key,
    this.initialLocation,
  });

  final GeoLocation? initialLocation;

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  GoogleMapController? _mapController;
  LatLng _selectedPosition = const LatLng(
    AppConstants.defaultLatitude,
    AppConstants.defaultLongitude,
  );
  GeoLocation? _selectedLocation;
  bool _isLoadingAddress = false;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _selectedLocation = widget.initialLocation;
    }
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
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: AppConstants.defaultZoom,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: _onMapTapped,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedPosition,
                      infoWindow: InfoWindow(
                        title: 'Selected Location',
                        snippet: _selectedLocation!.address,
                      ),
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search for a location...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 120,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'current_location',
              onPressed: _isLoadingCurrentLocation ? null : _getCurrentLocation,
              child: _isLoadingCurrentLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),

          // Selected Location Info
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected Location',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (_isLoadingAddress)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLocation!.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: () {
                          Navigator.of(context).pop(_selectedLocation);
                        },
                        text: 'Confirm Location',
                        icon: Icons.check,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _isLoadingAddress = true;
    });

    _getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
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
            latitude: latitude,
            longitude: longitude,
            address: address.isNotEmpty ? address : 'Unknown Address',
            city: place.locality ?? 'Unknown City',
          );
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _selectedLocation = GeoLocation(
            latitude: latitude,
            longitude: longitude,
            address: 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}',
            city: 'Unknown City',
          );
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedLocation = GeoLocation(
          latitude: latitude,
          longitude: longitude,
          address: 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}',
          city: 'Unknown City',
        );
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
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

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng newPosition = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedPosition = newPosition;
      });

      // Move camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(newPosition, 16.0),
      );

      // Get address for current location
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _showError('Failed to get current location: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      final List<Location> locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        final Location location = locations.first;
        final LatLng newPosition = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _selectedPosition = newPosition;
        });

        // Move camera to searched location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16.0),
        );

        // Get detailed address
        await _getAddressFromCoordinates(location.latitude, location.longitude);
      } else {
        _showError('Location not found');
      }
    } catch (e) {
      _showError('Search failed: ${e.toString()}');
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