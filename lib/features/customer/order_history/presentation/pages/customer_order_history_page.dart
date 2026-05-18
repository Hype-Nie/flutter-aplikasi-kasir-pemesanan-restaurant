import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/profile/presentation/widgets/shimmer_loading.dart';

import '../providers/customer_order_history_provider.dart';
import '../widgets/order_widgets.dart';
import 'customer_order_history_detail_page.dart';

const _accent = Color(0xFFFF460A);
const _bg = Color(0xFFF5F5F8);

class CustomerOrderHistoryPage extends ConsumerStatefulWidget {
  const CustomerOrderHistoryPage({super.key});

  @override
  ConsumerState<CustomerOrderHistoryPage> createState() =>
      _CustomerOrderHistoryPageState();
}

class _CustomerOrderHistoryPageState
    extends ConsumerState<CustomerOrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerOrderHistoryProvider.notifier).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerOrderHistoryProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CustomerOrderHistoryState state) {
    if (state.status == CustomerOrderHistoryStatus.loading) {
      return _buildShimmerList();
    }
    if (state.orders.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: state.orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) => OrderCard(
        order: state.orders[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CustomerOrderHistoryDetailPage(order: state.orders[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ShimmerEffect(
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => Container(
          height: 90,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              ShimmerBlock(width: 50, height: 50, radius: 12),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBlock(width: 120, height: 16),
                    SizedBox(height: 8),
                    ShimmerBlock(width: 160, height: 13),
                  ],
                ),
              ),
              ShimmerBlock(width: 70, height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: Color(0xFFC7C7C7),
            ),
            const SizedBox(height: 24),
            const Text(
              'No history yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hit the orange button down\nbelow to Create an order',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start ordering',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
