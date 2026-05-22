import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/core/utils/receipt_printer.dart';

import 'package:restaurant/shared/models/order.dart';
import 'package:restaurant/features/cashier/order_report/presentation/pages/cashier_order_report_page.dart';
import '../../riverpod/cashier_dashboard_provider.dart';

/// Home tab – dashboard overview with summary cards and recent activity.
class CashierHomeTab extends ConsumerWidget {
  const CashierHomeTab({super.key, required this.onSwitchTab});

  final void Function(int tabIndex) onSwitchTab;

  static const _accent = Color(0xFFFF4D06);

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatOrderTime(DateTime? orderTime) {
    if (orderTime == null) return '-';
    final localTime = orderTime.toLocal();
    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _buildOrderSearchText(Order order) {
    final orderTime = order.createdAt ?? order.updatedAt;
    final menuNames = order.items.map((item) => item.menuName).join(' ');
    final timeStr = _formatOrderTime(orderTime);
    return [
      order.orderNumber,
      order.orderType,
      order.paymentMethod,
      order.deliveryMethod,
      menuNames,
      timeStr,
    ].join(' ').toLowerCase();
  }

  bool _matchesQuery(Order order, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return _buildOrderSearchText(order).contains(normalized);
  }

  Future<void> _showPrintSelectionSheet(BuildContext context, List<Order> completedOrders) async {
    if (completedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No completed orders available to print')),
      );
      return;
    }

    // Sort to show newest first
    final sorted = [...completedOrders]..sort((a, b) {
        final bDate = b.createdAt ?? b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final aDate = a.createdAt ?? a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PrintReceiptSheet(
        orders: sorted,
        accentColor: _accent,
        formatPrice: _formatPrice,
        formatOrderTime: _formatOrderTime,
        matchesQuery: _matchesQuery,
        onPrint: (order) {
          Navigator.pop(ctx);
          ReceiptPrinter.printReceipt(context, order);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashierDashboardProvider);
    final isLoading = state.status == CashierDashboardStatus.loading;
    final orders = state.orders;
    final pending = state.pendingOrders;
    final completed = state.completedOrders;
    final revenue = state.totalRevenue;
    final recentOrders = orders.length > 5 ? orders.sublist(0, 5) : orders;

    // --- Greeting ---
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning,'
        : (hour < 17 ? 'Good afternoon,' : 'Good evening,');

    return RefreshIndicator(
      color: _accent,
      onRefresh: () =>
          ref.read(cashierDashboardProvider.notifier).fetchOrders(),
      child: ListView(
        key: const ValueKey('home'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        children: [
          // --- Greeting ---
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B8B8B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${state.userName} 👋',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 22),

          // --- Summary cards row ---
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Total Orders',
                  value: isLoading ? '...' : '${orders.length}',
                  color: _accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Revenue',
                  value: isLoading ? '...' : _formatPrice(revenue),
                  color: const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Pending',
                  value: isLoading ? '...' : '${pending.length}',
                  color: const Color(0xFFF39C12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completed',
                  value: isLoading ? '...' : '${completed.length}',
                  color: const Color(0xFF3498DB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // --- Recent orders section ---
          Row(
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121212),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => onSwitchTab(3),
                style: TextButton.styleFrom(foregroundColor: _accent),
                child: const Text(
                  'See all',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (isLoading && orders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: _accent)),
            )
          else if (recentOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No orders yet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ),
              ),
            )
          else
            ...recentOrders.map(
              (order) =>
                  _RecentOrderTile(order: order, formatPrice: _formatPrice),
            ),

          const SizedBox(height: 18),

          // --- Quick actions ---
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickActionChip(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                color: _accent,
                onTap: () =>
                    ref.read(cashierDashboardProvider.notifier).fetchOrders(),
              ),
              const SizedBox(width: 10),
              _QuickActionChip(
                icon: Icons.print_rounded,
                label: 'Print Receipt',
                color: const Color(0xFF3498DB),
                onTap: () => _showPrintSelectionSheet(context, completed),
              ),
              const SizedBox(width: 10),
              _QuickActionChip(
                icon: Icons.assessment_rounded,
                label: 'Report',
                color: const Color(0xFF2ECC71),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CashierOrderReportPage(),
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

class _PrintReceiptSheet extends StatefulWidget {
  const _PrintReceiptSheet({
    required this.orders,
    required this.accentColor,
    required this.formatPrice,
    required this.formatOrderTime,
    required this.matchesQuery,
    required this.onPrint,
  });

  final List<Order> orders;
  final Color accentColor;
  final String Function(double) formatPrice;
  final String Function(DateTime?) formatOrderTime;
  final bool Function(Order, String) matchesQuery;
  final void Function(Order) onPrint;

  @override
  State<_PrintReceiptSheet> createState() => _PrintReceiptSheetState();
}

class _PrintReceiptSheetState extends State<_PrintReceiptSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.orders
        .where((order) => widget.matchesQuery(order, _query))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
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
            'Select Receipt to Print',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search order number, menu, date (dd/MM)',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF6F6F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Showing ${filtered.length} of ${widget.orders.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B8B8B),
                ),
              ),
              const Spacer(),
              if (_query.trim().isNotEmpty)
                TextButton(
                  onPressed: _clearQuery,
                  style: TextButton.styleFrom(foregroundColor: widget.accentColor),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching orders found',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final order = filtered[index];
                      final orderTime = order.createdAt ?? order.updatedAt;
                      final timeStr = widget.formatOrderTime(orderTime);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: widget.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.receipt_long, color: widget.accentColor, size: 20),
                        ),
                        title: Text(
                          order.orderNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Text(
                          '$timeStr  •  ${widget.formatPrice(order.totalAmount)}',
                          style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 13),
                        ),
                        trailing: Icon(Icons.print_rounded, color: widget.accentColor, size: 22),
                        onTap: () => widget.onPrint(order),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------- Summary card ----------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B8B8B),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Recent order tile ----------

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order, required this.formatPrice});

  final Order order;
  final String Function(double) formatPrice;

  Color get _statusColor {
    switch (order.status) {
      case 'pending':
        return const Color(0xFFF39C12);
      case 'accepted':
        return const Color(0xFF3498DB);
      case 'preparing':
        return const Color(0xFF2ECC71);
      case 'ready':
        return const Color(0xFF1ABC9C);
      case 'served':
        return const Color(0xFF16A085);
      case 'completed':
        return const Color(0xFF27AE60);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF8B8B8B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: _statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.receipt_long_rounded,
                color: _statusColor,
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
                  order.orderNumber,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121212),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.orderType.replaceAll('_', ' ')} · ${formatPrice(order.totalAmount)}',
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Quick action chip ----------

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.20)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
