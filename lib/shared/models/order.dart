import 'package:equatable/equatable.dart';
import 'package:restaurant/shared/models/order_item.dart';

class Order extends Equatable {
  final int id;
  final String orderNumber;
  final int userId;
  final String orderType;
  final String? tableNumber;
  final String status;
  final String paymentMethod;
  final String deliveryMethod;
  final double totalAmount;
  final String? notes;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.orderType,
    this.tableNumber,
    required this.status,
    required this.paymentMethod,
    required this.deliveryMethod,
    required this.totalAmount,
    this.notes,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: (json['order_number'] ?? '').toString(),
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      orderType: (json['order_type'] ?? '').toString(),
      tableNumber: json['table_number']?.toString(),
      status: (json['status'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      deliveryMethod: (json['delivery_method'] ?? '').toString(),
      totalAmount: double.parse(json['total_amount'].toString()),
      notes: json['notes']?.toString(),
      items: json['order_items'] != null
          ? (json['order_items'] as List<dynamic>)
              .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
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

  Order copyWith({
    int? id,
    String? orderNumber,
    int? userId,
    String? orderType,
    String? tableNumber,
    String? status,
    String? paymentMethod,
    String? deliveryMethod,
    double? totalAmount,
    String? notes,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      orderType: orderType ?? this.orderType,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'user_id': userId,
        'order_type': orderType,
        'table_number': tableNumber,
        'status': status,
        'payment_method': paymentMethod,
        'delivery_method': deliveryMethod,
        'total_amount': totalAmount,
        'notes': notes,
        'order_items': items.map((e) => e.toJson()).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        userId,
        orderType,
        tableNumber,
        status,
        paymentMethod,
        deliveryMethod,
        totalAmount,
        notes,
        items,
        createdAt,
        updatedAt,
      ];
}
