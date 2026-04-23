import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant/features/customer/dashboard/presentation/pages/customer_dashboard_page.dart';

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

class _AuthLoginView extends StatefulWidget {
  const _AuthLoginView();

  @override
  State<_AuthLoginView> createState() => _AuthLoginViewState();
}

class _AuthLoginViewState extends State<_AuthLoginView> {
  bool _isLogin = true;
  int _slideDirection = 1;

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _signupName = TextEditingController();
  final _signupEmail = TextEditingController();
  final _signupPassword = TextEditingController();
  final _signupConfirmPassword = TextEditingController();

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signupName.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    _signupConfirmPassword.dispose();
    super.dispose();
  }

  void _switchTab(bool toLogin) {
    if (_isLogin == toLogin) return;
    setState(() {
      _slideDirection = toLogin ? -1 : 1;
      _isLogin = toLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFE8E8E8);
    const accent = Color(0xFFFF4D06);
    final size = MediaQuery.sizeOf(context);
    final isSmall = size.height < 720;
    final horizontal = (size.width * 0.10).clamp(20.0, 48.0);
    final topPanelHeight = (size.height * (isSmall ? 0.33 : 0.36)).clamp(
      230.0,
      320.0,
    );

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TopPanel(
                        height: topPanelHeight,
                        isLogin: _isLogin,
                        onLoginTap: () => _switchTab(true),
                        onSignupTap: () => _switchTab(false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontal,
                            isSmall ? 22 : 30,
                            horizontal,
                            26,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final offset = Tween<Offset>(
                                begin: Offset(_slideDirection * 0.16, 0),
                                end: Offset.zero,
                              ).animate(animation);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offset,
                                  child: child,
                                ),
                              );
                            },
                            child: _isLogin
                                ? _LoginForm(
                                    key: const ValueKey('login'),
                                    accent: accent,
                                    email: _loginEmail,
                                    password: _loginPassword,
                                  )
                                : _SignUpForm(
                                    key: const ValueKey('signup'),
                                    accent: accent,
                                    name: _signupName,
                                    email: _signupEmail,
                                    password: _signupPassword,
                                    confirmPassword: _signupConfirmPassword,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopPanel extends StatelessWidget {
  const _TopPanel({
    required this.height,
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignupTap,
  });

  final double height;
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.restaurant_menu_rounded,
            color: Color(0xFFFF8A26),
            size: 84,
          ),
          const SizedBox(height: 4),
          Container(
            width: 34,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFE12020),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),
          const Spacer(),
          _TabRow(
            isLogin: isLogin,
            onLoginTap: onLoginTap,
            onSignupTap: onSignupTap,
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignupTap,
  });

  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(label: 'Login', active: isLogin, onTap: onLoginTap),
          ),
          Expanded(
            child: _TabItem(
              label: 'Sign-up',
              active: !isLogin,
              onTap: onSignupTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: active
                    ? const Color(0xFF1B1B1B)
                    : const Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 3,
              width: double.infinity,
              color: active ? const Color(0xFFFF4D06) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    super.key,
    required this.accent,
    required this.email,
    required this.password,
  });

  final Color accent;
  final TextEditingController email;
  final TextEditingController password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LinedTextField(label: 'Email address', controller: email),
        const SizedBox(height: 24),
        _LinedTextField(label: 'Password', controller: password, obscure: true),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: accent,
          ),
          child: const Text(
            'Forgot passcode?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerDashboardPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: accent,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('Login'),
          ),
        ),
      ],
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    super.key,
    required this.accent,
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final Color accent;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LinedTextField(label: 'Full name', controller: name),
        const SizedBox(height: 16),
        _LinedTextField(label: 'Email address', controller: email),
        const SizedBox(height: 16),
        _LinedTextField(label: 'Password', controller: password, obscure: true),
        const SizedBox(height: 16),
        _LinedTextField(
          label: 'Confirm password',
          controller: confirmPassword,
          obscure: true,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: accent,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('Create account'),
          ),
        ),
      ],
    );
  }
}

class _LinedTextField extends StatefulWidget {
  const _LinedTextField({
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;

  @override
  State<_LinedTextField> createState() => _LinedTextFieldState();
}

class _LinedTextFieldState extends State<_LinedTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF959595),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111111),
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            border: InputBorder.none,
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF7A7A7A),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minHeight: 24,
              minWidth: 36,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(height: 1, color: const Color(0xFF8B8B8B)),
      ],
    );
  }
}
