import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/auth_logout_provider.dart';

class AuthLogoutPage extends ConsumerStatefulWidget {
  const AuthLogoutPage({super.key});

  @override
  ConsumerState<AuthLogoutPage> createState() => _AuthLogoutPageState();
}

class _AuthLogoutPageState extends ConsumerState<AuthLogoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authLogoutProvider.notifier).started();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authLogoutProvider);
    return const _AuthLogoutView();
  }
}

class _AuthLogoutView extends StatelessWidget {
  const _AuthLogoutView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
