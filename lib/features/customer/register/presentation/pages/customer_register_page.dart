import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_register_bloc.dart';
import '../bloc/customer_register_event.dart';

class CustomerRegisterPage extends StatelessWidget {
  const CustomerRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerRegisterBloc()..add(const CustomerRegisterStarted()),
      child: const _CustomerRegisterView(),
    );
  }
}

class _CustomerRegisterView extends StatelessWidget {
  const _CustomerRegisterView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
