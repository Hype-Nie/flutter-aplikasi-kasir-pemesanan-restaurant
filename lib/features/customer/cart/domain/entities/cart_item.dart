import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
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

  @override
  List<Object?> get props => [id, name, price, imageUrl, quantity];
}
