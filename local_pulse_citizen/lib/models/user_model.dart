import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? phone;
  final String? city;
  final String? profileImageUrl;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phone,
    this.city,
    this.profileImageUrl,
    this.role = 'citizen',
    required this.createdAt,
    this.lastLoginAt,
  });

  // Legacy getter for backward compatibility
  String get name => displayName ?? email.split('@')[0];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'city': city,
      'profileImageUrl': profileImageUrl,
      'role': role,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString(),
      phone: map['phone']?.toString(),
      city: map['city']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      role: map['role']?.toString() ?? 'citizen',
      createdAt: map['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'] is int 
                  ? map['createdAt'] 
                  : int.tryParse(map['createdAt'].toString()) ?? 0
            )
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(
              map['lastLoginAt'] is int 
                  ? map['lastLoginAt'] 
                  : int.tryParse(map['lastLoginAt'].toString()) ?? 0
            )
          : null,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel.fromMap(json);

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phone,
    String? city,
    String? profileImageUrl,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
    id, email, displayName, phone, city, profileImageUrl, role, createdAt, lastLoginAt
  ];
}