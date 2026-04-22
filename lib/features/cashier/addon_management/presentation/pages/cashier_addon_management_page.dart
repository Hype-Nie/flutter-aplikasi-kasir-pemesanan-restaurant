import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cashier_addon_management_bloc.dart';
import '../bloc/cashier_addon_management_event.dart';

class CashierAddonManagementPage extends StatelessWidget {
  const CashierAddonManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CashierAddonManagementBloc()..add(const CashierAddonManagementStarted()),
      child: const _CashierAddonManagementView(),
    );
  }
}

class _CashierAddonManagementView extends StatelessWidget {
  const _CashierAddonManagementView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
