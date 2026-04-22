import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_menu_detail_bloc.dart';
import '../bloc/customer_menu_detail_event.dart';

class CustomerMenuDetailPage extends StatelessWidget {
  const CustomerMenuDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerMenuDetailBloc()..add(const CustomerMenuDetailStarted()),
      child: const _CustomerMenuDetailView(),
    );
  }
}

class _CustomerMenuDetailView extends StatelessWidget {
  const _CustomerMenuDetailView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
