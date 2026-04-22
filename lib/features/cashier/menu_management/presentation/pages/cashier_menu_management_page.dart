import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_menu_management_bloc.dart';
import '../bloc/cashier_menu_management_event.dart';

class CashierMenuManagementPage extends StatelessWidget {
  const CashierMenuManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierMenuManagementBloc()..add(const CashierMenuManagementStarted()),
      child: const _CashierMenuManagementView(),
    );
  }
}

class _CashierMenuManagementView extends StatelessWidget {
  const _CashierMenuManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
