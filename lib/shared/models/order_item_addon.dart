import 'package:equatable/equatable.dart';

class OrderItemAddon extends Equatable {
  final int id;
  final int orderItemId;
  final int addonId;
  final String addonName;
  final double addonPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderItemAddon({
    required this.id,
    required this.orderItemId,
    required this.addonId,
    this.addonName = '',
    required this.addonPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItemAddon.fromJson(Map<String, dynamic> json) {
    return OrderItemAddon(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderItemId: int.tryParse(json['order_item_id'].toString()) ?? 0,
      addonId: int.tryParse(json['addon_id'].toString()) ?? 0,
      addonName: _parseAddonName(json),
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
        'addon_name': addonName,
        'addon_price': addonPrice,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  OrderItemAddon copyWith({
    int? id,
    int? orderItemId,
    int? addonId,
    String? addonName,
    double? addonPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItemAddon(
      id: id ?? this.id,
      orderItemId: orderItemId ?? this.orderItemId,
      addonId: addonId ?? this.addonId,
      addonName: addonName ?? this.addonName,
      addonPrice: addonPrice ?? this.addonPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, orderItemId, addonId, addonName, addonPrice, createdAt, updatedAt];

  static String _parseAddonName(Map<String, dynamic> json) {
    if (json['addon'] is Map) {
      final addon = json['addon'] as Map<String, dynamic>;
      if (addon['name'] is String) return addon['name'] as String;
    }
    if (json['addon_name'] is String) return json['addon_name'] as String;
    return '';
  }
}
