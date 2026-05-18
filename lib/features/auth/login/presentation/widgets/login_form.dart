import 'package:flutter/material.dart';
import 'package:restaurant/config/strings/auth_strings.dart';

import 'lined_text_field.dart';

class LoginForm extends StatelessWidget {
  final Color accent;
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onLogin;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.accent,
    required this.email,
    required this.password,
    required this.onLogin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinedTextField(
          label: 'Email address',
          hint: AuthStrings.emailHint,
          controller: email,
        ),
        const SizedBox(height: 24),
        LinedTextField(
          label: 'Password',
          hint: AuthStrings.passwordHint,
          controller: password,
          obscure: true,
        ),
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
            onPressed: onLogin,
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
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Login'),
          ),
        ),
      ],
    );
  }
}
