import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_payment_gateway_bloc.dart';
import '../bloc/customer_payment_gateway_event.dart';

class CustomerPaymentGatewayPage extends StatelessWidget {
  const CustomerPaymentGatewayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomerPaymentGatewayBloc()..add(const CustomerPaymentGatewayStarted()),
      child: const _CustomerPaymentGatewayView(),
    );
  }
}

class _CustomerPaymentGatewayView extends StatelessWidget {
  const _CustomerPaymentGatewayView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
