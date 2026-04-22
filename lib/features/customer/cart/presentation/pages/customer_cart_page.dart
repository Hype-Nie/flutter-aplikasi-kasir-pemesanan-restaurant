import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_cart_bloc.dart';
import '../bloc/customer_cart_event.dart';

class CustomerCartPage extends StatelessWidget {
  const CustomerCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerCartBloc()..add(const CustomerCartStarted()),
      child: const _CustomerCartView(),
    );
  }
}

class _CustomerCartView extends StatelessWidget {
  const _CustomerCartView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
