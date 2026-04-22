import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_checkout_bloc.dart';
import '../bloc/customer_checkout_event.dart';

class CustomerCheckoutPage extends StatelessWidget {
  const CustomerCheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerCheckoutBloc()..add(const CustomerCheckoutStarted()),
      child: const _CustomerCheckoutView(),
    );
  }
}

class _CustomerCheckoutView extends StatelessWidget {
  const _CustomerCheckoutView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
