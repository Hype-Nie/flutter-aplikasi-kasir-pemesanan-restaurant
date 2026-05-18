import 'package:flutter/material.dart';
import 'package:restaurant/config/strings/auth_strings.dart';

import 'lined_text_field.dart';

class SignUpForm extends StatelessWidget {
  final Color accent;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmPassword;
  final VoidCallback onSignUp;
  final bool isLoading;

  const SignUpForm({
    super.key,
    required this.accent,
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.onSignUp,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinedTextField(
          label: 'Full name',
          hint: AuthStrings.fullNameHint,
          controller: name,
        ),
        const SizedBox(height: 16),
        LinedTextField(
          label: 'Email address',
          hint: AuthStrings.emailHint,
          controller: email,
        ),
        const SizedBox(height: 16),
        LinedTextField(
          label: 'Password',
          hint: AuthStrings.passwordHint,
          controller: password,
          obscure: true,
        ),
        const SizedBox(height: 16),
        LinedTextField(
          label: 'Confirm password',
          hint: AuthStrings.confirmPasswordHint,
          controller: confirmPassword,
          obscure: true,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onSignUp,
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
                : const Text('Create account'),
          ),
        ),
      ],
    );
  }
}
