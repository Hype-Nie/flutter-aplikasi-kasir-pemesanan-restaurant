import 'package:equatable/equatable.dart';

class Menu extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? price;
  final String? imageUrl;
  final int? categoryId;
  final bool isAvailable;

  const Menu({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.categoryId,
    this.isAvailable = true,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] as String?,
      imageUrl: json['image'] as String?,
      categoryId: json['category_id'] as int?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, imageUrl, categoryId, isAvailable];
}
