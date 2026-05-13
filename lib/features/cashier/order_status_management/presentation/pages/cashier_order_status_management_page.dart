import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      ref.read(cashierOrderStatusManagementProvider.notifier).started();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cashierOrderStatusManagementProvider);
    return const _CashierOrderStatusManagementView();
  }
}

class _CashierOrderStatusManagementView extends StatelessWidget {
  const _CashierOrderStatusManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
