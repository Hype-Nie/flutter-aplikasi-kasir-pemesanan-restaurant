import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_dashboard_bloc.dart';
import '../bloc/customer_dashboard_event.dart';

class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerDashboardBloc()..add(const CustomerDashboardStarted()),
      child: const _CustomerDashboardView(),
    );
  }
}

class _CustomerDashboardView extends StatelessWidget {
  const _CustomerDashboardView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
