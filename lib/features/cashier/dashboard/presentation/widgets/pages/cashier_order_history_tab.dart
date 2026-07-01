import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/core/utils/receipt_printer.dart';
import 'package:restaurant/features/cashier/order_history/presentation/pages/cashier_order_history_detail_page.dart';

import 'package:restaurant/shared/models/order.dart';
import '../../riverpod/cashier_dashboard_provider.dart';

/// Order History tab – past completed / cancelled orders with filter.
class CashierOrderHistoryTab extends ConsumerStatefulWidget {
  const CashierOrderHistoryTab({super.key});

  @override
  ConsumerState<CashierOrderHistoryTab> createState() =>
      _CashierOrderHistoryTabState();
}

class _CashierOrderHistoryTabState
    extends ConsumerState<CashierOrderHistoryTab> {
  static const _accent = Color(0xFFFF4D06);

  String _selectedFilter = 'All';
  static const _filterOptions = ['All', 'Completed', 'Cancelled'];

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final l = dt.toLocal();
    return '${l.day}/${l.month}/${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierDashboardProvider);
    final isLoading = state.status == CashierDashboardStatus.loading;

    List<Order> filteredOrders;
    switch (_selectedFilter) {
      case 'Completed':
        filteredOrders = state.completedOrders;
        break;
      case 'Cancelled':
        filteredOrders = state.cancelledOrders;
        break;
      default:
        filteredOrders = state.historyOrders;
    }

    final completed = state.completedOrders;
    final cancelled = state.cancelledOrders;

    return RefreshIndicator(
      color: _accent,
      onRefresh: () =>
          ref.read(cashierDashboardProvider.notifier).fetchOrders(),
      child: ListView(
        key: const ValueKey('history'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        children: [
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, size: 18, color: _accent),
                  const SizedBox(width: 10),
                  Text(
                    _selectedFilter,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF121212),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down_rounded, size: 24, color: _accent),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MiniStat(
                label: 'Total',
                value: '${filteredOrders.length}',
                color: _accent,
              ),
              const SizedBox(width: 10),
              _MiniStat(
                label: 'Completed',
                value: '${completed.length}',
                color: const Color(0xFF2ECC71),
              ),
              const SizedBox(width: 10),
              _MiniStat(
                label: 'Cancelled',
                value: '${cancelled.length}',
                color: const Color(0xFFE74C3C),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Order List',
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
          else if (filteredOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 56,
                      color: _accent.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No order history',
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
            ...filteredOrders.map(
              (order) => _HistoryTile(
                order: order,
                formattedPrice: _formatPrice(order.totalAmount),
                formattedDate: _formatDate(order.createdAt),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CashierOrderHistoryDetailPage(order: order),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121212),
              ),
            ),
            const SizedBox(height: 18),
            ..._filterOptions.map((option) {
              final isSelected = option == _selectedFilter;
              return ListTile(
                onTap: () {
                  setState(() => _selectedFilter = option);
                  Navigator.pop(ctx);
                },
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected ? _accent : const Color(0xFF8B8B8B),
                ),
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF121212)
                        : const Color(0xFF8B8B8B),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.order,
    required this.formattedPrice,
    required this.formattedDate,
    required this.onTap,
  });

  final Order order;
  final String formattedPrice;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = order.status == 'completed';
    final color = isCompleted
        ? const Color(0xFF2ECC71)
        : const Color(0xFFE74C3C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121212),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF4D06),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            if (isCompleted)
              IconButton(
                icon: const Icon(
                  Icons.print_rounded,
                  color: Color(0xFFFF4D06),
                  size: 22,
                ),
                onPressed: () => ReceiptPrinter.printReceipt(context, order),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
          ],
        ),
      ),
    );
  }
}
