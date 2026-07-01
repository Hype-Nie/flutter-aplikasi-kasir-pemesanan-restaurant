import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/features/cashier/order_history/presentation/pages/cashier_order_history_detail_page.dart';
import 'package:restaurant/shared/models/order.dart';
import '../../riverpod/cashier_dashboard_provider.dart';

/// Incoming Orders tab – lists pending orders from customers.
class CashierIncomingOrdersTab extends ConsumerStatefulWidget {
  const CashierIncomingOrdersTab({super.key});

  @override
  ConsumerState<CashierIncomingOrdersTab> createState() =>
      _CashierIncomingOrdersTabState();
}

class _CashierIncomingOrdersTabState
    extends ConsumerState<CashierIncomingOrdersTab> {
  int _selectedFilter = 0;
  static const _filters = ['All', 'Dine-in', 'Takeaway'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierDashboardProvider);
    final isLoading = state.status == CashierDashboardStatus.loading;
    var pendingOrders = state.pendingOrders;

    // Apply filter
    if (_selectedFilter == 1) {
      pendingOrders = pendingOrders
          .where((o) => o.orderType == 'dine_in')
          .toList();
    } else if (_selectedFilter == 2) {
      pendingOrders = pendingOrders
          .where((o) => o.orderType == 'takeaway')
          .toList();
    }

    return RefreshIndicator(
      color: const Color(0xFFFF4D06),
      onRefresh: () =>
          ref.read(cashierDashboardProvider.notifier).fetchOrders(),
      child: ListView(
        key: const ValueKey('incoming'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        children: [
          // --- Filter chips ---
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final active = i == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFFF4D06) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? const Color(0xFFFF4D06)
                            : const Color(0xFFD0D0D0),
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : const Color(0xFF8B8B8B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          if (isLoading && state.orders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF4D06)),
              ),
            )
          else if (pendingOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 56,
                      color: const Color(0xFFFF4D06).withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No incoming orders',
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
            ...pendingOrders.map(
              (order) => _IncomingOrderCard(
                order: order,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CashierOrderHistoryDetailPage(order: order),
                    ),
                  );
                },
                onAccept: () async {
                  final success = await ref
                      .read(cashierDashboardProvider.notifier)
                      .updateOrderStatus(order.id, 'accepted');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Order ${order.orderNumber} accepted'
                              : 'Failed to accept order',
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
                onDecline: () async {
                  final success = await ref
                      .read(cashierDashboardProvider.notifier)
                      .updateOrderStatus(order.id, 'cancelled');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Order ${order.orderNumber} declined'
                              : 'Failed to decline order',
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
              ),
            ),
        ],
      ),
    );
  }
}

class _IncomingOrderCard extends StatefulWidget {
  const _IncomingOrderCard({
    required this.order,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  final Order order;
  final VoidCallback onTap;
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;

  @override
  State<_IncomingOrderCard> createState() => _IncomingOrderCardState();
}

class _IncomingOrderCardState extends State<_IncomingOrderCard> {
  bool _loading = false;

  static const _accent = Color(0xFFFF4D06);

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDineIn = widget.order.orderType == 'dine_in';

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDineIn
                      ? Icons.table_restaurant_rounded
                      : Icons.takeout_dining_rounded,
                  color: _accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                      '${isDineIn ? 'Dine-in' : 'Takeaway'} · ${_formatTime(widget.order.createdAt)}',
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
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF39C12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF0F0F0)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(label: widget.order.paymentMethod.replaceAll('_', ' ')),
              _InfoPill(label: widget.order.deliveryMethod.replaceAll('_', ' ')),
              if ((widget.order.tableNumber ?? '').isNotEmpty)
                _InfoPill(label: widget.order.tableNumber!),
            ],
          ),
          const SizedBox(height: 12),

          // Total
          Text(
            'Total: ${_formatPrice(widget.order.totalAmount)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B8B8B),
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            await widget.onDecline();
                            if (mounted) setState(() => _loading = false);
                          },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD0D0D0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            await widget.onAccept();
                            if (mounted) setState(() => _loading = false);
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Tap for detail',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B8B8B),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}
