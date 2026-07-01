import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/customer_change_password_provider.dart';

class CustomerChangePasswordPage extends ConsumerWidget {
  const CustomerChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerChangePasswordProvider);
    return const _CustomerChangePasswordView();
  }
}

class _CustomerChangePasswordView extends StatelessWidget {
  const _CustomerChangePasswordView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
