import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_incoming_order_management_bloc.dart';
import '../bloc/cashier_incoming_order_management_event.dart';

class CashierIncomingOrderManagementPage extends StatelessWidget {
  const CashierIncomingOrderManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierIncomingOrderManagementBloc()..add(const CashierIncomingOrderManagementStarted()),
      child: const _CashierIncomingOrderManagementView(),
    );
  }
}

class _CashierIncomingOrderManagementView extends StatelessWidget {
  const _CashierIncomingOrderManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
