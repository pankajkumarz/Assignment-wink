import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<Subcategory> subcategories;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.subcategories,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props => [
        id,
        name,
        description,
        icon,
        subcategories,
        isActive,
        createdAt,
        updatedAt,
      ];

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<Subcategory>? subcategories,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Subcategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;

  const Subcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  @override
  List<Object> get props => [id, name, description, icon, isActive];

  Subcategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    bool? isActive,
  }) {
    return Subcategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }
}