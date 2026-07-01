import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final int orderId;
  final String status;
  final String checkoutUrl;
  final String amount;
  final String? paymentMethod;
  final String? paidAt;

  const Payment({
    required this.id,
    required this.orderId,
    required this.status,
    required this.checkoutUrl,
    required this.amount,
    this.paymentMethod,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as int,
    orderId: int.tryParse(json['order_id'].toString()) ?? 0,
    status: json['status'] as String? ?? 'pending',
    checkoutUrl: json['checkout_url'] as String? ?? '',
    amount: json['amount']?.toString() ?? '0',
    paymentMethod: json['payment_method'] as String?,
    paidAt: json['paid_at'] as String?,
  );

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isExpired => status == 'expired';
  bool get isFailed => status == 'failed';

  @override
  List<Object?> get props => [
    id, orderId, status, checkoutUrl, amount, paymentMethod, paidAt,
  ];
}
