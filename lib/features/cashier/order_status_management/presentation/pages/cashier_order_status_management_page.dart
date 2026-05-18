import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/cashier/order_history/presentation/pages/cashier_order_history_detail_page.dart';

import '../riverpod/cashier_order_status_management_provider.dart';

class CashierOrderStatusManagementPage extends ConsumerStatefulWidget {
  const CashierOrderStatusManagementPage({super.key});

  @override
  ConsumerState<CashierOrderStatusManagementPage> createState() =>
      _CashierOrderStatusManagementPageState();
}

class _CashierOrderStatusManagementPageState
    extends ConsumerState<CashierOrderStatusManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierOrderStatusManagementProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierOrderStatusManagementProvider);

    ref.listen(cashierOrderStatusManagementProvider, (prev, next) {
      if (next.status == CashierOrderStatusManagementStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
      if (next.status == CashierOrderStatusManagementStatus.success &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    });

    return _View(
      state: state,
      onRefresh: () =>
          ref.read(cashierOrderStatusManagementProvider.notifier).fetchOrders(),
      onUpdateStatus: (id, s) => ref
          .read(cashierOrderStatusManagementProvider.notifier)
          .updateOrderStatus(id, s),
    );
  }
}

class _View extends StatelessWidget {
  const _View({
    required this.state,
    required this.onRefresh,
    required this.onUpdateStatus,
  });

  final CashierOrderStatusManagementState state;
  final Future<void> Function() onRefresh;
  final Future<bool> Function(int id, String newStatus) onUpdateStatus;

  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  String _fmt(double p) =>
      'Rp ${p.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  Color _statusColor(String s) {
    switch (s) {
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

  String _nextStatus(String c) {
    switch (c) {
      case 'accepted':
        return 'preparing';
      case 'preparing':
        return 'completed';
      default:
        return c;
    }
  }

  String _nextLabel(String c) {
    switch (c) {
      case 'accepted':
        return 'Start Preparing';
      case 'preparing':
        return 'Complete Order';
      default:
        return 'Done';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        state.status == CashierOrderStatusManagementStatus.loading;
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
                    'Order Status',
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
                      '${orders.length} active',
                      style: TextStyle(
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
                  : orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: const Color(
                              0xFF2ECC71,
                            ).withValues(alpha: 0.30),
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
                          const SizedBox(height: 4),
                          const Text(
                            'No active orders at the moment',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8B8B8B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: _accent,
                      onRefresh: onRefresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                        itemCount: orders.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final o = orders[i];
                          final sc = _statusColor(o.status);
                          final canAdvance =
                              o.status == 'accepted' || o.status == 'preparing';
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CashierOrderHistoryDetailPage(order: o),
                                ),
                              );
                            },
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              o.orderNumber,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF121212),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${o.orderType.replaceAll('_', ' ')} • ${o.paymentMethod}',
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
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: sc.withValues(alpha: 0.10),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          o.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: sc,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _InfoPill(
                                        label: o.paymentMethod.replaceAll(
                                          '_',
                                          ' ',
                                        ),
                                      ),
                                      _InfoPill(
                                        label: o.deliveryMethod.replaceAll(
                                          '_',
                                          ' ',
                                        ),
                                      ),
                                      if ((o.tableNumber ?? '').isNotEmpty)
                                        _InfoPill(label: o.tableNumber!),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _fmt(o.totalAmount),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _accent,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      if (canAdvance) ...[
                                        Expanded(
                                          child: SizedBox(
                                            height: 42,
                                            child: OutlinedButton(
                                              onPressed: () => onUpdateStatus(
                                                o.id,
                                                'cancelled',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(
                                                  0xFFE74C3C,
                                                ),
                                                side: const BorderSide(
                                                  color: Color(0xFFE74C3C),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: SizedBox(
                                          height: 42,
                                          child: ElevatedButton(
                                            onPressed: canAdvance
                                                ? () => onUpdateStatus(
                                                    o.id,
                                                    _nextStatus(o.status),
                                                  )
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: _accent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Text(
                                              _nextLabel(o.status),
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
