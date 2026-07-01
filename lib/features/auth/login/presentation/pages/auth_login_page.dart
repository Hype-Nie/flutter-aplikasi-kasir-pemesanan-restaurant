import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/auth/login/presentation/widgets/auth_top_panel.dart';
import 'package:restaurant/features/auth/login/presentation/widgets/login_form.dart';
import 'package:restaurant/features/auth/login/presentation/widgets/sign_up_form.dart';
import 'package:restaurant/features/auth/login/presentation/riverpod/auth_login_provider.dart';
import 'package:restaurant/features/auth/register/presentation/riverpod/auth_register_provider.dart';
import 'package:restaurant/features/cashier/dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:restaurant/features/customer/dashboard/presentation/pages/customer_dashboard_page.dart';

const _accent = Color(0xFFFF4D06);
const _bg = Color(0xFFE8E8E8);

class AuthLoginPage extends ConsumerStatefulWidget {
  const AuthLoginPage({super.key});

  @override
  ConsumerState<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends ConsumerState<AuthLoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authLoginProvider.notifier).reset();
      ref.read(authRegisterProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) => const _AuthLoginView();
}

class _AuthLoginView extends ConsumerStatefulWidget {
  const _AuthLoginView();

  @override
  ConsumerState<_AuthLoginView> createState() => _AuthLoginViewState();
}

class _AuthLoginViewState extends ConsumerState<_AuthLoginView> {
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
    for (final c in [
      _loginEmail,
      _loginPassword,
      _signupName,
      _signupEmail,
      _signupPassword,
      _signupConfirmPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _switchTab(bool toLogin) {
    if (_isLogin == toLogin) return;
    setState(() {
      _slideDirection = toLogin ? -1 : 1;
      _isLogin = toLogin;
    });
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
  );

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(authLoginProvider);
    final registerState = ref.watch(authRegisterProvider);

    ref.listen(authLoginProvider, (_, next) {
      if (next.status == AuthLoginStatus.success && next.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => next.user!.isCashier
                ? const CashierDashboardPage()
                : const CustomerDashboardPage(),
          ),
        );
        return;
      }
      if (next.status == AuthLoginStatus.failure && next.message.isNotEmpty) {
        _showError(next.message);
      }
    });
    ref.listen(authRegisterProvider, (_, next) {
      if (next.status == AuthRegisterStatus.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerDashboardPage()),
        );
        return;
      }
      if (next.status == AuthRegisterStatus.failure &&
          next.message.isNotEmpty) {
        _showError(next.message);
      }
    });

    final size = MediaQuery.sizeOf(context);
    final isSmall = size.height < 720;
    final horizontal = (size.width * 0.10).clamp(20.0, 48.0);
    final topPanelHeight = (size.height * (isSmall ? 0.33 : 0.36)).clamp(
      230.0,
      320.0,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
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
                        AuthTopPanel(
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
                                  ? LoginForm(
                                      key: const ValueKey('login'),
                                      accent: _accent,
                                      email: _loginEmail,
                                      password: _loginPassword,
                                      isLoading:
                                          loginState.status ==
                                          AuthLoginStatus.loading,
                                      onLogin: () {
                                        if (loginState.status !=
                                            AuthLoginStatus.loading) {
                                          ref
                                              .read(authLoginProvider.notifier)
                                              .login(
                                                _loginEmail.text.trim(),
                                                _loginPassword.text,
                                              );
                                        }
                                      },
                                    )
                                  : SignUpForm(
                                      key: const ValueKey('signup'),
                                      accent: _accent,
                                      name: _signupName,
                                      email: _signupEmail,
                                      password: _signupPassword,
                                      confirmPassword: _signupConfirmPassword,
                                      isLoading:
                                          registerState.status ==
                                          AuthRegisterStatus.loading,
                                      onSignUp: () {
                                        if (registerState.status !=
                                            AuthRegisterStatus.loading) {
                                          ref
                                              .read(
                                                authRegisterProvider.notifier,
                                              )
                                              .register(
                                                name: _signupName.text.trim(),
                                                email: _signupEmail.text.trim(),
                                                password: _signupPassword.text,
                                                passwordConfirmation:
                                                    _signupConfirmPassword.text,
                                              );
                                        }
                                      },
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
      ),
    );
  }
}
