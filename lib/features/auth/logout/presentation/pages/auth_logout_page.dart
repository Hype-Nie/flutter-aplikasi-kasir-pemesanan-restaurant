import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_logout_bloc.dart';
import '../bloc/auth_logout_event.dart';

class AuthLogoutPage extends StatelessWidget {
  const AuthLogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthLogoutBloc()..add(const AuthLogoutStarted()),
      child: const _AuthLogoutView(),
    );
  }
}

class _AuthLogoutView extends StatelessWidget {
  const _AuthLogoutView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
