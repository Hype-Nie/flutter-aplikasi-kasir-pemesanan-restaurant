import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _toDisplayText(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Order? _latestOrder(List<Order> orders) {
    if (orders.isEmpty) return null;
    final sorted = [...orders]
      ..sort((a, b) {
        final bDate =
            b.createdAt ??
            b.updatedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final aDate =
            a.createdAt ??
            a.updatedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    return sorted.first;
  }

  Future<void> _printLatestReceipt(
    BuildContext context,
    List<Order> orders,
  ) async {
    final order = _latestOrder(orders);
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No order available to print receipt')),
      );
      return;
    }

    try {
      final receiptDoc = pw.Document();
      final printedAt = DateTime.now();

      receiptDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a6,
          margin: const pw.EdgeInsets.all(14),
          build: (_) {
            final orderTime = order.createdAt ?? order.updatedAt ?? printedAt;
            final itemWidgets = order.items.isEmpty
                ? <pw.Widget>[
                    pw.Text(
                      'No item details available',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ]
                : order.items
                      .map(
                        (item) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 5),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(
                                flex: 2,
                                child: pw.Text(
                                  '${item.quantity}x ${item.menuName}',
                                  style: const pw.TextStyle(fontSize: 10),
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Text(
                                _formatPrice(item.subtotal),
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList();

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text(
                    'Restaurant Cashier',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(height: 1),
                pw.SizedBox(height: 8),
                pw.Text('Order: ${order.orderNumber}'),
                pw.Text('Date: ${_formatDateTime(orderTime)}'),
                pw.Text('Type: ${_toDisplayText(order.orderType)}'),
                pw.Text('Status: ${_toDisplayText(order.status)}'),
                pw.Text('Payment: ${_toDisplayText(order.paymentMethod)}'),
                pw.SizedBox(height: 8),
                pw.Divider(height: 1),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Items',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 6),
                ...itemWidgets,
                pw.SizedBox(height: 6),
                pw.Divider(height: 1),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _formatPrice(order.totalAmount),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    'Printed: ${_formatDateTime(printedAt)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await receiptDoc.save();
      await Printing.layoutPdf(
        name: 'receipt_${order.orderNumber}.pdf',
        onLayout: (_) async => pdfBytes,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt ${order.orderNumber} sent to print')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to print receipt')),
        );
      }
    }
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
                onTap: () => _printLatestReceipt(context, orders),
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
