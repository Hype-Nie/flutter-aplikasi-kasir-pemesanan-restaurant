import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_profile_bloc.dart';
import '../bloc/customer_profile_event.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerProfileBloc()..add(const CustomerProfileStarted()),
      child: const _CustomerProfileView(),
    );
  }
}

class _CustomerProfileView extends StatelessWidget {
  const _CustomerProfileView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
