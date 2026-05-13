import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/cashier_incoming_order_management_provider.dart';

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
      ref.read(cashierIncomingOrderManagementProvider.notifier).started();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cashierIncomingOrderManagementProvider);
    return const _CashierIncomingOrderManagementView();
  }
}

class _CashierIncomingOrderManagementView extends StatelessWidget {
  const _CashierIncomingOrderManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
