import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_order_report_bloc.dart';
import '../bloc/cashier_order_report_event.dart';

class CashierOrderReportPage extends StatelessWidget {
  const CashierOrderReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierOrderReportBloc()..add(const CashierOrderReportStarted()),
      child: const _CashierOrderReportView(),
    );
  }
}

class _CashierOrderReportView extends StatelessWidget {
  const _CashierOrderReportView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
