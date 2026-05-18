import 'package:equatable/equatable.dart';
import 'package:restaurant/shared/models/order_item.dart';

class Order extends Equatable {
  final int id;
  final String orderNumber;
  final int userId;
  final String orderType;
  final String status;
  final String paymentMethod;
  final String deliveryMethod;
  final double totalAmount;
  final List<OrderItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.orderType,
    required this.status,
    required this.paymentMethod,
    required this.deliveryMethod,
    required this.totalAmount,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as int,
      orderType: json['order_type'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      deliveryMethod: json['delivery_method'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'user_id': userId,
    'order_type': orderType,
    'status': status,
    'payment_method': paymentMethod,
    'delivery_method': deliveryMethod,
    'total_amount': totalAmount,
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
    status,
    paymentMethod,
    deliveryMethod,
    totalAmount,
    items,
    createdAt,
    updatedAt,
  ];
}
