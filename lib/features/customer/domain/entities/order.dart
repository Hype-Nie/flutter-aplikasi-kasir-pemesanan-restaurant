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
      id: int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      orderType: json['order_type']?.toString() ?? '',
      tableNumber: json['table_number']?.toString(),
      status: json['status']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString(),
      deliveryMethod: json['delivery_method']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
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
