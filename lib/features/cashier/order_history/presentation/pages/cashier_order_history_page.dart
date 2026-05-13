import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/cashier_order_history_provider.dart';

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
      ref.read(cashierOrderHistoryProvider.notifier).started();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cashierOrderHistoryProvider);
    return const _CashierOrderHistoryView();
  }
}

class _CashierOrderHistoryView extends StatelessWidget {
  const _CashierOrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
