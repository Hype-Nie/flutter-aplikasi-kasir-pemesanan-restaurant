import 'package:equatable/equatable.dart';

class Addon extends Equatable {
  final int id;
  final String name;
  final String? price;

  const Addon({
    required this.id,
    required this.name,
    this.price,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, price];
}
