import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final int menuId;
  final int quantity;
  final String unitPrice;
  final String subtotal;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      menuId: json['menu_id'] as int,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as String,
      subtotal: json['subtotal'] as String,
    );
  }

  @override
  List<Object?> get props => [id, orderId, menuId, quantity, unitPrice, subtotal];
}

class OrderItemAddon extends Equatable {
  final int id;
  final int orderItemId;
  final int addonId;
  final String addonPrice;

  const OrderItemAddon({
    required this.id,
    required this.orderItemId,
    required this.addonId,
    required this.addonPrice,
  });

  factory OrderItemAddon.fromJson(Map<String, dynamic> json) {
    return OrderItemAddon(
      id: json['id'] as int,
      orderItemId: json['order_item_id'] as int,
      addonId: json['addon_id'] as int,
      addonPrice: json['addon_price'] as String,
    );
  }

  @override
  List<Object?> get props => [id, orderItemId, addonId, addonPrice];
}
