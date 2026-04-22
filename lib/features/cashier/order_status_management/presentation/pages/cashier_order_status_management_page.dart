import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_order_status_management_bloc.dart';
import '../bloc/cashier_order_status_management_event.dart';

class CashierOrderStatusManagementPage extends StatelessWidget {
  const CashierOrderStatusManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierOrderStatusManagementBloc()..add(const CashierOrderStatusManagementStarted()),
      child: const _CashierOrderStatusManagementView(),
    );
  }
}

class _CashierOrderStatusManagementView extends StatelessWidget {
  const _CashierOrderStatusManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
