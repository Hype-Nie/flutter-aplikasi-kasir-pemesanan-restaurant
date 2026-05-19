import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/shared/models/order.dart';
import '../riverpod/cashier_order_detail_provider.dart';
import '../widgets/detail_row.dart';
import '../widgets/item_row.dart';

class CashierOrderHistoryDetailPage extends ConsumerStatefulWidget {
  const CashierOrderHistoryDetailPage({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<CashierOrderHistoryDetailPage> createState() =>
      _CashierOrderHistoryDetailPageState();
}

class _CashierOrderHistoryDetailPageState
    extends ConsumerState<CashierOrderHistoryDetailPage> {
  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(cashierOrderDetailProvider.notifier)
          .fetchOrderDetail(widget.order);
    });
  }

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
      case 'accepted':
        return const Color(0xFF3498DB);
      case 'preparing':
        return const Color(0xFFF39C12);
      default:
        return _accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierOrderDetailProvider);
    final order = state.order ?? widget.order;
    final items = state.items.isNotEmpty ? state.items : order.items;
    final statusColor = _statusColor(order.status);

    ref.listen(cashierOrderDetailProvider, (prev, next) {
      if (next.status == CashierOrderDetailStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    });

    final isLoading = state.status == CashierOrderDetailStatus.loading;

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
      body: RefreshIndicator(
        color: _accent,
        onRefresh: () => ref
            .read(cashierOrderDetailProvider.notifier)
            .fetchOrderDetail(order),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          children: [
            if (isLoading) ...[
              const SizedBox(height: 180),
              const Center(
                child: CircularProgressIndicator(color: _accent),
              ),
              const SizedBox(height: 240),
            ] else ...[
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
                    DetailRow(
                      label: 'Date & Time',
                      value: _formatDate(order.createdAt ?? order.updatedAt),
                    ),
                    const SizedBox(height: 10),
                    DetailRow(
                      label: 'Order Type',
                      value: _toLabel(order.orderType),
                    ),
                    if (order.tableNumber != null &&
                        order.tableNumber!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      DetailRow(
                        label: 'Table',
                        value: order.tableNumber!,
                      ),
                    ],
                    const SizedBox(height: 10),
                    DetailRow(
                      label: 'Payment Method',
                      value: _toLabel(order.paymentMethod),
                    ),
                    const SizedBox(height: 10),
                    DetailRow(
                      label: 'Delivery Method',
                      value: _toLabel(order.deliveryMethod),
                    ),
                    if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      DetailRow(
                        label: 'Notes',
                        value: order.notes!,
                      ),
                    ],
                    const Divider(height: 24),
                    DetailRow(
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
                child: items.isEmpty
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
                          for (var i = 0; i < items.length; i++) ...[
                            ItemRow(
                              name: items[i].menuName,
                              quantity: items[i].quantity,
                              subtotal: _formatPrice(items[i].subtotal),
                            ),
                            if (items[i].addons.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: items[i].addons.map((addon) {
                                    final addonName = addon.addonName.isNotEmpty
                                        ? addon.addonName
                                        : 'Addon #${addon.addonId}';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F3F3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$addonName (+${_formatPrice(addon.addonPrice)})',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6B6B6B),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                            if (i != items.length - 1) const Divider(height: 20),
                          ],
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
