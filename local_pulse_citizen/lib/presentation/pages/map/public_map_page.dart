import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/injection_container.dart' as di;
import '../../../domain/entities/issue.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/issue_card.dart';
import '../issues/issue_detail_page.dart';

class PublicMapPage extends StatefulWidget {
  const PublicMapPage({super.key});

  @override
  State<PublicMapPage> createState() => _PublicMapPageState();
}

class _PublicMapPageState extends State<PublicMapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Issue> _issues = [];
  Issue? _selectedIssue;
  String _selectedFilter = 'all';

  final List<String> _filterOptions = [
    'all',
    'submitted',
    'in_progress',
    'resolved',
    'daily_life',
    'emergency',
    'general',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<IssuesBloc>()
        ..add(const PublicIssuesWatchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Issues Map'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        body: BlocListener<IssuesBloc, IssuesState>(
          listener: (context, state) {
            if (state is PublicIssuesLoaded) {
              setState(() {
                _issues = state.issues;
                _updateMarkers();
              });
            }
          },
          child: Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    AppConstants.defaultLatitude,
                    AppConstants.defaultLongitude,
                  ),
                  zoom: AppConstants.defaultZoom,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: _markers,
                onTap: (_) {
                  setState(() {
                    _selectedIssue = null;
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Loading Indicator
              BlocBuilder<IssuesBloc, IssuesState>(
                builder: (context, state) {
                  if (state is IssuesLoading) {
                    return const Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('Loading issues...'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Filter Chip
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getFilterDisplayName(_selectedFilter),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Issue Count
              Positioned(
                top: 16,
                left: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      '${_getFilteredIssues().length} issues',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),

              // Selected Issue Card
              if (_selectedIssue != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IssueCard(
                          issue: _selectedIssue!,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => IssueDetailPage(
                                  issueId: _selectedIssue!.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              // Legend
              Positioned(
                bottom: _selectedIssue != null ? 200 : 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legend',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem('Submitted', Colors.orange),
                        _buildLegendItem('In Progress', Colors.blue),
                        _buildLegendItem('Resolved', Colors.green),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _updateMarkers() {
    final filteredIssues = _getFilteredIssues();
    
    setState(() {
      _markers = filteredIssues.map((issue) {
        return Marker(
          markerId: MarkerId(issue.id),
          position: LatLng(
            issue.location.latitude,
            issue.location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(issue.status),
          ),
          infoWindow: InfoWindow(
            title: issue.title,
            snippet: '${issue.category} • ${issue.status}',
          ),
          onTap: () {
            setState(() {
              _selectedIssue = issue;
            });
            
            // Move camera to selected marker
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(issue.location.latitude, issue.location.longitude),
                15.0,
              ),
            );
          },
        );
      }).toSet();
    });
  }

  List<Issue> _getFilteredIssues() {
    if (_selectedFilter == 'all') {
      return _issues;
    }

    return _issues.where((issue) {
      switch (_selectedFilter) {
        case 'submitted':
        case 'in_progress':
        case 'resolved':
          return issue.status == _selectedFilter;
        case 'daily_life':
        case 'emergency':
        case 'general':
          return issue.category == _selectedFilter;
        default:
          return true;
      }
    }).toList();
  }

  double _getMarkerColor(String status) {
    switch (status) {
      case 'submitted':
        return BitmapDescriptor.hueOrange;
      case 'acknowledged':
        return BitmapDescriptor.hueBlue;
      case 'in_progress':
        return BitmapDescriptor.hueViolet;
      case 'resolved':
        return BitmapDescriptor.hueGreen;
      case 'closed':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Issues';
      case 'submitted':
        return 'Submitted';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'daily_life':
        return 'Daily Life';
      case 'emergency':
        return 'Emergency';
      case 'general':
        return 'General';
      default:
        return filter;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Issues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Text(_getFilterDisplayName(filter)),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _selectedIssue = null;
                  _updateMarkers();
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}