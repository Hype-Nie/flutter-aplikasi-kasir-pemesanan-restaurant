import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/auth/login/presentation/pages/auth_login_page.dart';

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
      ref.read(authLogoutProvider.notifier).logout();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authLogoutProvider, (_, next) {
      if (next.status == AuthLogoutStatus.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthLoginPage()),
          (_) => false,
        );
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFFF4D06)),
      ),
    );
  }
}
