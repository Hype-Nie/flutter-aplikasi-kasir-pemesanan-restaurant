import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_category_management_bloc.dart';
import '../bloc/cashier_category_management_event.dart';

class CashierCategoryManagementPage extends StatelessWidget {
  const CashierCategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierCategoryManagementBloc()..add(const CashierCategoryManagementStarted()),
      child: const _CashierCategoryManagementView(),
    );
  }
}

class _CashierCategoryManagementView extends StatelessWidget {
  const _CashierCategoryManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
