import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final int quantity;
  final List<int> addonIds;
  final List<String> addonNames;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.addonIds = const [],
    this.addonNames = const [],
  });

  CartItem copyWith({
    int? quantity,
    List<int>? addonIds,
    List<String>? addonNames,
  }) => CartItem(
    id: id,
    name: name,
    price: price,
    imageUrl: imageUrl,
    quantity: quantity ?? this.quantity,
    addonIds: addonIds ?? this.addonIds,
    addonNames: addonNames ?? this.addonNames,
  );

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as int,
    name: json['name'] as String,
    price: json['price'] as String,
    imageUrl: json['image_url'] as String,
    quantity: json['quantity'] as int? ?? 1,
    addonIds:
        (json['addon_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ??
        const [],
    addonNames:
        (json['addon_names'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    imageUrl,
    quantity,
    addonIds,
    addonNames,
  ];
}
