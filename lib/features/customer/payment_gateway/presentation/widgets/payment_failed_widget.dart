import 'package:flutter/material.dart';

class PaymentFailedView extends StatelessWidget {
  final bool isExpired;
  final VoidCallback onRetry;
  final VoidCallback onBackToCart;
  const PaymentFailedView({
    super.key,
    required this.isExpired,
    required this.onRetry,
    required this.onBackToCart,
  });

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFDF2C2C);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: red.withValues(alpha: 0.1), shape: BoxShape.circle,
            ),
            child: Icon(
              isExpired ? Icons.timer_off : Icons.cancel,
              size: 64, color: red,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isExpired ? 'Payment Expired' : 'Payment Failed',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isExpired
                ? 'Your payment link has expired.\nPlease try again.'
                : 'Something went wrong.\nPlease try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14, color: Colors.black54, height: 1.5,
            ),
          ),
          const Spacer(flex: 1),
          SizedBox(
            width: double.infinity, height: 64,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF460A), elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Try Again', style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600,
              )),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBackToCart,
            child: const Text('Back to Cart', style: TextStyle(
              color: Colors.black54, fontSize: 15,
            )),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
