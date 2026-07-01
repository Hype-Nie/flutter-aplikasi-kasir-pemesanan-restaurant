import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/customer_register_provider.dart';

class CustomerRegisterPage extends ConsumerWidget {
  const CustomerRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerRegisterProvider);
    return const _CustomerRegisterView();
  }
}

class _CustomerRegisterView extends StatelessWidget {
  const _CustomerRegisterView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
