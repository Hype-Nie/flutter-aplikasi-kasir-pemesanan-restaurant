import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/cashier_incoming_order_management_provider.dart';
import '../widgets/order_card.dart';

class CashierIncomingOrderManagementPage extends ConsumerStatefulWidget {
  const CashierIncomingOrderManagementPage({super.key});

  @override
  ConsumerState<CashierIncomingOrderManagementPage> createState() =>
      _CashierIncomingOrderManagementPageState();
}

class _CashierIncomingOrderManagementPageState
    extends ConsumerState<CashierIncomingOrderManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(cashierIncomingOrderManagementProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierIncomingOrderManagementProvider);

    ref.listen(cashierIncomingOrderManagementProvider, (prev, next) {
      if (next.status == CashierIncomingOrderManagementStatus.failure &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
      if (next.status == CashierIncomingOrderManagementStatus.success &&
          next.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    });

    return _CashierIncomingOrderManagementView(
      state: state,
      onRefresh: () => ref
          .read(cashierIncomingOrderManagementProvider.notifier)
          .fetchOrders(),
      onAccept: (int id) => ref
          .read(cashierIncomingOrderManagementProvider.notifier)
          .updateOrderStatus(id, 'accepted'),
      onReject: (int id) => ref
          .read(cashierIncomingOrderManagementProvider.notifier)
          .updateOrderStatus(id, 'cancelled'),
    );
  }
}

class _CashierIncomingOrderManagementView extends StatelessWidget {
  const _CashierIncomingOrderManagementView({
    required this.state,
    required this.onRefresh,
    required this.onAccept,
    required this.onReject,
  });

  final CashierIncomingOrderManagementState state;
  final Future<void> Function() onRefresh;
  final Future<bool> Function(int id) onAccept;
  final Future<bool> Function(int id) onReject;

  static const _bg = Color(0xFFE7E7E7);
  static const _accent = Color(0xFFFF4D06);

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        state.status == CashierIncomingOrderManagementStatus.loading;
    final orders = state.orders;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
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
                            Icons.inbox_rounded,
                            size: 64,
                            color: _accent.withValues(alpha: 0.25),
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
                          const SizedBox(height: 4),
                          const Text(
                            'New orders from customers will appear here',
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
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 350 + (i * 80)),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            ),
                            child: OrderCard(
                              order: orders[i],
                              formattedPrice: _formatPrice(
                                orders[i].totalAmount,
                              ),
                              formattedTime: _formatTime(orders[i].createdAt),
                              accent: _accent,
                              onAccept: () => onAccept(orders[i].id),
                              onReject: () => onReject(orders[i].id),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
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
            'Incoming Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF121212),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${state.orders.length} pending',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
