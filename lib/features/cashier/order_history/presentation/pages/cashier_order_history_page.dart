import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_order_history_bloc.dart';
import '../bloc/cashier_order_history_event.dart';

class CashierOrderHistoryPage extends StatelessWidget {
  const CashierOrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierOrderHistoryBloc()..add(const CashierOrderHistoryStarted()),
      child: const _CashierOrderHistoryView(),
    );
  }
}

class _CashierOrderHistoryView extends StatelessWidget {
  const _CashierOrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
