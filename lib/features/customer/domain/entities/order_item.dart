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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      menuId: int.tryParse(json['menu_id']?.toString() ?? '') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    menuId,
    quantity,
    unitPrice,
    subtotal,
  ];
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
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderItemId: int.tryParse(json['order_item_id']?.toString() ?? '') ?? 0,
      addonId: int.tryParse(json['addon_id']?.toString() ?? '') ?? 0,
      addonPrice: json['addon_price']?.toString() ?? '0',
    );
  }

  @override
  List<Object?> get props => [id, orderItemId, addonId, addonPrice];
}
