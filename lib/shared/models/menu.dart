import 'package:equatable/equatable.dart';

class Menu extends Equatable {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Menu({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.image,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      image: json['image'] as String?,
      isAvailable: json['is_available'] is bool
          ? json['is_available'] as bool
          : (json['is_available'] == 1),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'image': image,
        'is_available': isAvailable,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        description,
        price,
        image,
        isAvailable,
        createdAt,
        updatedAt,
      ];
}
