import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/shared/models/order.dart';
import '../../riverpod/cashier_dashboard_provider.dart';

/// Order Status tab – track and update the status of active orders.
class CashierOrderStatusTab extends ConsumerWidget {
  const CashierOrderStatusTab({super.key});

  static const _accent = Color(0xFFFF4D06);

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF39C12);
      case 'accepted':
        return const Color(0xFF3498DB);
      case 'preparing':
        return const Color(0xFF2ECC71);
      case 'completed':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF8B8B8B);
    }
  }

  String _nextStatus(String current) {
    switch (current) {
      case 'accepted':
        return 'preparing';
      case 'preparing':
        return 'completed';
      default:
        return current;
    }
  }

  String _nextLabel(String current) {
    switch (current) {
      case 'accepted':
        return 'Start Preparing';
      case 'preparing':
        return 'Complete Order';
      default:
        return 'Done';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashierDashboardProvider);
    final isLoading = state.status == CashierDashboardStatus.loading;
    final activeOrders = state.activeOrders;

    final accepted = activeOrders.where((o) => o.status == 'accepted').length;
    final preparing = activeOrders.where((o) => o.status == 'preparing').length;
    final completed = state.completedOrders.length;

    return RefreshIndicator(
      color: _accent,
      onRefresh: () =>
          ref.read(cashierDashboardProvider.notifier).fetchOrders(),
      child: ListView(
        key: const ValueKey('status'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        children: [
          // --- Status summary row ---
          SizedBox(
            height: 90,
            child: Row(
              children: [
                _StatusSummaryCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Accepted',
                  count: accepted,
                  color: const Color(0xFF3498DB),
                ),
                const SizedBox(width: 10),
                _StatusSummaryCard(
                  icon: Icons.outdoor_grill_rounded,
                  label: 'Preparing',
                  count: preparing,
                  color: const Color(0xFF2ECC71),
                ),
                const SizedBox(width: 10),
                _StatusSummaryCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  count: completed,
                  color: const Color(0xFF27AE60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // --- Active orders list ---
          const Text(
            'Active Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 12),

          if (isLoading && state.orders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: _accent)),
            )
          else if (activeOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.30),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'All caught up!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activeOrders.map((order) {
              final sc = _statusColor(order.status);
              final nextSt = _nextStatus(order.status);
              return _OrderStatusCard(
                order: order,
                statusColor: sc,
                formattedPrice: _formatPrice(order.totalAmount),
                nextLabel: _nextLabel(order.status),
                onAdvance: () async {
                  final success = await ref
                      .read(cashierDashboardProvider.notifier)
                      .updateOrderStatus(order.id, nextSt);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Order ${order.orderNumber} → ${nextSt.toUpperCase()}'
                              : 'Failed to update order status',
                        ),
                        backgroundColor: success
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFE74C3C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                onCancel: () async {
                  final success = await ref
                      .read(cashierDashboardProvider.notifier)
                      .updateOrderStatus(order.id, 'cancelled');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Order ${order.orderNumber} cancelled'
                              : 'Failed to cancel order',
                        ),
                        backgroundColor: success
                            ? const Color(0xFFF39C12)
                            : const Color(0xFFE74C3C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              );
            }),
        ],
      ),
    );
  }
}

class _StatusSummaryCard extends StatelessWidget {
  const _StatusSummaryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '$count orders',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusCard extends StatefulWidget {
  const _OrderStatusCard({
    required this.order,
    required this.statusColor,
    required this.formattedPrice,
    required this.nextLabel,
    required this.onAdvance,
    required this.onCancel,
  });

  final Order order;
  final Color statusColor;
  final String formattedPrice;
  final String nextLabel;
  final Future<void> Function() onAdvance;
  final Future<void> Function() onCancel;

  @override
  State<_OrderStatusCard> createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<_OrderStatusCard> {
  bool _loading = false;

  static const _accent = Color(0xFFFF4D06);

  int get _step {
    switch (widget.order.status) {
      case 'pending':
        return 0;
      case 'accepted':
        return 1;
      case 'preparing':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: widget.statusColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.orderNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.order.orderType.replaceAll('_', ' ')} · ${widget.formattedPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- Progress indicator ---
          _OrderProgress(step: _step),

          const SizedBox(height: 12),

          // --- Action buttons ---
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            await widget.onCancel();
                            if (mounted) setState(() => _loading = false);
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE74C3C),
                      side: const BorderSide(color: Color(0xFFE74C3C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            await widget.onAdvance();
                            if (mounted) setState(() => _loading = false);
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _accent.withValues(alpha: 0.10),
                      foregroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.nextLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['Pending', 'Accepted', 'Preparing', 'Completed'];
    return Row(
      children: List.generate(labels.length, (i) {
        final done = i < step;
        final current = i == step;
        final color = done || current
            ? const Color(0xFF2ECC71)
            : const Color(0xFFD0D0D0);
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : null,
              ),
              if (i < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFD0D0D0),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
