import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_dashboard_bloc.dart';
import '../bloc/cashier_dashboard_event.dart';

class CashierDashboardPage extends StatelessWidget {
  const CashierDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierDashboardBloc()..add(const CashierDashboardStarted()),
      child: const _CashierDashboardView(),
    );
  }
}

class _CashierDashboardView extends StatelessWidget {
  const _CashierDashboardView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
