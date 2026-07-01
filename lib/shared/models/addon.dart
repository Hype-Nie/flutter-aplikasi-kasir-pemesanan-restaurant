import 'package:equatable/equatable.dart';

class Addon extends Equatable {
  final int id;
  final String name;
  final double price;
  final String type;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Addon({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      type: json['type'] as String,
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
    'name': name,
    'price': price,
    'type': type,
    'is_available': isAvailable,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    type,
    isAvailable,
    createdAt,
    updatedAt,
  ];
}
