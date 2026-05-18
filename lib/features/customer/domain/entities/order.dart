import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final int id;
  final String orderNumber;
  final int userId;
  final String orderType;
  final String? tableNumber;
  final String status;
  final String? paymentMethod;
  final String? deliveryMethod;
  final String totalAmount;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.orderType,
    this.tableNumber,
    required this.status,
    this.paymentMethod,
    this.deliveryMethod,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as int,
      orderType: json['order_type'] as String,
      tableNumber: json['table_number'] as String?,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
      deliveryMethod: json['delivery_method'] as String?,
      totalAmount: json['total_amount'] as String,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';

  static const _months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.day} ${_months[dt.month]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  String get formattedTotal {
    try {
      final amount = double.parse(totalAmount);
      final whole = amount.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
      return 'Rp $whole';
    } catch (_) {
      return totalAmount;
    }
  }

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
    createdAt,
    updatedAt,
  ];
}
