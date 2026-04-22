import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_change_password_bloc.dart';
import '../bloc/customer_change_password_event.dart';

class CustomerChangePasswordPage extends StatelessWidget {
  const CustomerChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerChangePasswordBloc()..add(const CustomerChangePasswordStarted()),
      child: const _CustomerChangePasswordView(),
    );
  }
}

class _CustomerChangePasswordView extends StatelessWidget {
  const _CustomerChangePasswordView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
