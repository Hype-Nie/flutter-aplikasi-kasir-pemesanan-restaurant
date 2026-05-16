import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final int menuId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      menuId: json['menu_id'] as int,
      quantity: json['quantity'] as int,
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
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
        'order_id': orderId,
        'menu_id': menuId,
        'quantity': quantity,
        'unit_price': unitPrice,
        'subtotal': subtotal,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, orderId, menuId, quantity, unitPrice, subtotal, createdAt, updatedAt];
}
