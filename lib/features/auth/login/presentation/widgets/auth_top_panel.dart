import 'package:flutter/material.dart';

class AuthTopPanel extends StatelessWidget {
  final double height;
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onSignupTap;

  const AuthTopPanel({
    super.key,
    required this.height,
    required this.isLogin,
    required this.onLoginTap,
    required this.onSignupTap,
  });

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
