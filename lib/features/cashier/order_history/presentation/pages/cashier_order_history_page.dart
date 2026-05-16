import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/shared/models/order.dart';

import '../riverpod/cashier_order_history_provider.dart';
import 'cashier_order_history_detail_page.dart';

class CashierOrderHistoryPage extends ConsumerStatefulWidget {
  const CashierOrderHistoryPage({super.key});

  @override
  ConsumerState<CashierOrderHistoryPage> createState() =>
      _CashierOrderHistoryPageState();
}

class _CashierOrderHistoryPageState
    extends ConsumerState<CashierOrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierOrderHistoryProvider.notifier).fetchOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierOrderHistoryProvider);

    ref.listen(cashierOrderHistoryProvider, (prev, next) {
      if (next.status == CashierOrderHistoryStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    });

    return _View(
      state: state,
      onRefresh: () =>
          ref.read(cashierOrderHistoryProvider.notifier).fetchOrderHistory(),
      onOrderTap: (order) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CashierOrderHistoryDetailPage(order: order),
          ),
        );
      },
    );
  }
}

class _View extends StatelessWidget {
  const _View({
    required this.state,
    required this.onRefresh,
    required this.onOrderTap,
  });

  final CashierOrderHistoryState state;
  final Future<void> Function() onRefresh;
  final void Function(Order order) onOrderTap;

  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  String _fmt(double p) {
    return 'Rp ${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    final l = dt.toLocal();
    return '${l.day}/${l.month}/${l.year} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == CashierOrderHistoryStatus.loading;
    final orders = state.orders;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 14, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF121212),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${orders.length} orders',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading && orders.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : RefreshIndicator(
                      color: _accent,
                      onRefresh: onRefresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                        itemCount: orders.isEmpty ? 1 : orders.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          if (orders.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 80),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.history_rounded,
                                      size: 64,
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
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Completed and cancelled orders will appear here',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF8B8B8B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final o = orders[i];
                          final isCompleted = o.status == 'completed';
                          final statusColor = isCompleted
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE74C3C);

                          return InkWell(
                            onTap: () => onOrderTap(o),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
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
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isCompleted
                                          ? Icons.check_circle_rounded
                                          : Icons.cancel_rounded,
                                      color: statusColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          o.orderNumber,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF121212),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _fmtDate(o.createdAt),
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
                                        _fmt(o.totalAmount),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _accent,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          o.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFFB0B0B0),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
