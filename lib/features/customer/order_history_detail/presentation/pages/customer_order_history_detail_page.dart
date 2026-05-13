import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/customer_order_history_detail_provider.dart';

class CustomerOrderHistoryDetailPage extends ConsumerWidget {
  const CustomerOrderHistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerOrderHistoryDetailProvider);
    return const _CustomerOrderHistoryDetailView();
  }
}

class _CustomerOrderHistoryDetailView extends StatelessWidget {
  const _CustomerOrderHistoryDetailView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
