import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/domain/entities/order.dart';

import '../providers/customer_order_history_provider.dart';
import '../widgets/order_detail_widgets.dart';
import '../widgets/order_widgets.dart';

const _accent = Color(0xFFFF460A);
const _bg = Color(0xFFF5F5F8);

class CustomerOrderHistoryDetailPage extends ConsumerStatefulWidget {
  final Order order;
  const CustomerOrderHistoryDetailPage({super.key, required this.order});

  @override
  ConsumerState<CustomerOrderHistoryDetailPage> createState() =>
      _CustomerOrderHistoryDetailPageState();
}

class _CustomerOrderHistoryDetailPageState
    extends ConsumerState<CustomerOrderHistoryDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(customerOrderHistoryProvider.notifier)
          .fetchOrderDetail(widget.order.id);
    });
  }

  Color _statusColor(String status) {
    if (status == 'completed') return Colors.green;
    if (status == 'pending') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerOrderHistoryProvider);
    final order = state.orderDetail ?? widget.order;
    final statusColor = _statusColor(order.status);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order ${order.orderNumber}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        if (state.status == CustomerOrderHistoryStatus.loading) {
          return const OrderDetailShimmer();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailCard(children: [
                DetailRow(
                    label: 'Status',
                    value: order.status[0].toUpperCase() +
                        order.status.substring(1),
                    valueColor: statusColor,
                    isBold: true),
                const Divider(height: 32),
                DetailRow(label: 'Order Date', value: order.formattedDate),
                const Divider(height: 32),
                DetailRow(label: 'Order ID', value: order.orderNumber),
                if (order.tableNumber != null) ...[
                  const Divider(height: 32),
                  DetailRow(label: 'Table', value: order.tableNumber!),
                ],
              ]),
              const SizedBox(height: 24),
              const Text('Items',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DetailCard(children: buildOrderItemList(state)),
              const SizedBox(height: 24),
              const Text('Payment Details',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DetailCard(children: [
                DetailRow(
                    label: 'Payment Method',
                    value: order.paymentMethod ?? '-'),
                const Divider(height: 32),
                DetailRow(
                    label: 'Delivery Method',
                    value: order.deliveryMethod ?? '-'),
                const Divider(height: 32),
                DetailRow(
                    label: 'Total',
                    value: order.formattedTotal,
                    isBold: true,
                    valueColor: _accent,
                    fontSize: 18),
              ]),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text('Re-order',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
