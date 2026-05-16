import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final int quantity;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity ?? this.quantity,
      );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as String,
        imageUrl: json['image_url'] as String,
        quantity: json['quantity'] as int? ?? 1,
      );

  @override
  List<Object?> get props => [id, name, price, imageUrl, quantity];
}
