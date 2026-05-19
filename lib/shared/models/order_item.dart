import 'package:equatable/equatable.dart';
import 'package:restaurant/shared/models/order_item_addon.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final int menuId;
  final String menuName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final List<OrderItemAddon> addons;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuId,
    this.menuName = 'Unknown',
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.addons = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderId: int.tryParse(json['order_id'].toString()) ?? 0,
      menuId: int.tryParse(json['menu_id'].toString()) ?? 0,
      menuName: _parseMenuName(json),
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      addons: json['order_item_addons'] != null
          ? (json['order_item_addons'] as List<dynamic>)
              .map((e) => OrderItemAddon.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
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
        'menu_name': menuName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'subtotal': subtotal,
        'order_item_addons': addons.map((e) => e.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? menuId,
    String? menuName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    List<OrderItemAddon>? addons,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      addons: addons ?? this.addons,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [
        id,
        orderId,
        menuId,
        menuName,
        quantity,
        unitPrice,
        subtotal,
        addons,
        createdAt,
        updatedAt,
      ];

  static String _parseMenuName(Map<String, dynamic> json) {
    // From nested eager-loaded menu object
    if (json['menu'] is Map) {
      final menu = json['menu'] as Map<String, dynamic>;
      if (menu['name'] is String) return menu['name'] as String;
    }
    // From flat field
    if (json['menu_name'] is String) return json['menu_name'] as String;
    return 'Item #${json['menu_id']}';
  }
}
