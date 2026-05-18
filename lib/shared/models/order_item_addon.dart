import 'package:equatable/equatable.dart';

class OrderItemAddon extends Equatable {
  final int id;
  final int orderItemId;
  final int addonId;
  final double addonPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderItemAddon({
    required this.id,
    required this.orderItemId,
    required this.addonId,
    required this.addonPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItemAddon.fromJson(Map<String, dynamic> json) {
    return OrderItemAddon(
      id: json['id'] as int,
      orderItemId: json['order_item_id'] as int,
      addonId: json['addon_id'] as int,
      addonPrice: double.parse(json['addon_price'].toString()),
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
    'order_item_id': orderItemId,
    'addon_id': addonId,
    'addon_price': addonPrice,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    orderItemId,
    addonId,
    addonPrice,
    createdAt,
    updatedAt,
  ];
}
