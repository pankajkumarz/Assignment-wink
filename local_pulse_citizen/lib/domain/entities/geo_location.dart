import 'package:equatable/equatable.dart';

class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String city;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
  });

  @override
  List<Object> get props => [latitude, longitude, address, city];

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
    };
  }

  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'] ?? '',
      city: map['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => toMap();
  
  factory GeoLocation.fromJson(Map<String, dynamic> json) => fromMap(json);
}