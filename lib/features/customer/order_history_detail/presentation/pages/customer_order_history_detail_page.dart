import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_order_history_detail_bloc.dart';
import '../bloc/customer_order_history_detail_event.dart';

class CustomerOrderHistoryDetailPage extends StatelessWidget {
  const CustomerOrderHistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerOrderHistoryDetailBloc()..add(const CustomerOrderHistoryDetailStarted()),
      child: const _CustomerOrderHistoryDetailView(),
    );
  }
}

class _CustomerOrderHistoryDetailView extends StatelessWidget {
  const _CustomerOrderHistoryDetailView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
