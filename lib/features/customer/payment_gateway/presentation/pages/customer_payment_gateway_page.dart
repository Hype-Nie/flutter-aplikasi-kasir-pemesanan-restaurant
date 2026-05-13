import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/customer_payment_gateway_provider.dart';

class CustomerPaymentGatewayPage extends ConsumerWidget {
  const CustomerPaymentGatewayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerPaymentGatewayProvider);
    return const _CustomerPaymentGatewayView();
  }
}

class _CustomerPaymentGatewayView extends StatelessWidget {
  const _CustomerPaymentGatewayView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
