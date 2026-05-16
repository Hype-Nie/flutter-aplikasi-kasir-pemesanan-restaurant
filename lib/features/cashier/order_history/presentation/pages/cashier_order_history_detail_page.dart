import 'package:flutter/material.dart';

import 'package:restaurant/shared/models/order.dart';

class CashierOrderHistoryDetailPage extends StatelessWidget {
  const CashierOrderHistoryDetailPage({super.key, required this.order});

  final Order order;

  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final l = dt.toLocal();
    return '${l.day}/${l.month}/${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  String _toLabel(String value) {
    if (value.isEmpty) return '-';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF2ECC71);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      default:
        return _accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
        ),
        title: const Text(
          'Order Detail',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF121212),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF121212),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _toLabel(order.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'Date & Time',
                    value: _formatDate(order.createdAt ?? order.updatedAt),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Order Type',
                    value: _toLabel(order.orderType),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Payment Method',
                    value: _toLabel(order.paymentMethod),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Delivery Method',
                    value: _toLabel(order.deliveryMethod),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Total',
                    value: _formatPrice(order.totalAmount),
                    valueColor: _accent,
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: order.items.isEmpty
                  ? const Text(
                      'Item details are not available for this order.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B8B8B),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < order.items.length; i++) ...[
                          _ItemRow(
                            name: order.items[i].menuName,
                            quantity: order.items[i].quantity,
                            subtotal: _formatPrice(order.items[i].subtotal),
                          ),
                          if (i != order.items.length - 1)
                            const Divider(height: 20),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF121212),
    this.bold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B8B8B),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.name,
    required this.quantity,
    required this.subtotal,
  });

  final String name;
  final int quantity;
  final String subtotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF121212),
            ),
          ),
        ),
        Text(
          'x$quantity',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B8B8B),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          subtotal,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF4D06),
          ),
        ),
      ],
    );
  }
}
