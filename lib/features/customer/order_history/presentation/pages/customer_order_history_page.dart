import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_order_history_bloc.dart';
import '../bloc/customer_order_history_event.dart';

class CustomerOrderHistoryPage extends StatelessWidget {
  const CustomerOrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerOrderHistoryBloc()..add(const CustomerOrderHistoryStarted()),
      child: const _CustomerOrderHistoryView(),
    );
  }
}

class _CustomerOrderHistoryView extends StatelessWidget {
  const _CustomerOrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
