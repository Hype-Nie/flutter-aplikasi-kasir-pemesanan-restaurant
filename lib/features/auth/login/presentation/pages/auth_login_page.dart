import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_login_bloc.dart';
import '../bloc/auth_login_event.dart';

class AuthLoginPage extends StatelessWidget {
  const AuthLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthLoginBloc()..add(const AuthLoginStarted()),
      child: const _AuthLoginView(),
    );
  }
}

class _AuthLoginView extends StatelessWidget {
  const _AuthLoginView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}
