import 'package:flutter/material.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/auth/login/presentation/pages/auth_login_page.dart';
import 'package:restaurant/features/cashier/dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:restaurant/features/customer/dashboard/presentation/pages/customer_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final hasToken = await TokenStorage.hasToken();
    if (!hasToken) {
      _navigate(const AuthLoginPage());
      return;
    }

    final role = await TokenStorage.getRole();
    final route = role == 'cashier'
        ? const CashierDashboardPage()
        : const CustomerDashboardPage();
    _navigate(route);
  }

  void _navigate(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFF4D06))),
    );
  }
}
