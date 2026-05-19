import 'package:flutter/material.dart';

/// App-wide utility helpers.
class AppHelpers {
  /// Shows a consistent floating SnackBar for the customer app.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final accent = isError ? const Color(0xFFDF2C2C) : const Color(0xFFFF4D06);
    
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
        duration: const Duration(seconds: 3),
        elevation: 4,
      ),
    );
  }
}
