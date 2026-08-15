import 'package:flutter/material.dart';

class PaymentPendingView extends StatefulWidget {
  final VoidCallback onOpenPayment;
  final VoidCallback onRefresh;
  const PaymentPendingView({super.key, required this.onOpenPayment, required this.onRefresh});

  @override
  State<PaymentPendingView> createState() => _PaymentPendingViewState();
}

class _PaymentPendingViewState extends State<PaymentPendingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF460A);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payment, size: 56, color: accent),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Waiting for payment...', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          const Text(
            'Complete your payment in the\nbrowser to continue',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const Spacer(flex: 1),
          SizedBox(
            width: double.infinity, height: 64,
            child: ElevatedButton.icon(
              onPressed: widget.onOpenPayment,
              icon: const Icon(Icons.open_in_new, color: Colors.white, size: 20),
              label: const Text('Open Payment Page', style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600,
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent, elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 64,
            child: OutlinedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh_rounded, color: accent, size: 22),
              label: const Text('Refresh Status', style: TextStyle(
                color: accent, fontSize: 17, fontWeight: FontWeight.w600,
              )),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: accent, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PaymentSuccessView extends StatefulWidget {
  final String orderNumber;
  final VoidCallback onViewOrder;
  const PaymentSuccessView({
    super.key, required this.orderNumber, required this.onViewOrder,
  });

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 120, height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 64, color: green),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Payment Successful!', style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 8),
          Text('Order #${widget.orderNumber}', style: const TextStyle(
            fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500,
          )),
          const SizedBox(height: 4),
          const Text('Thank you for your order', style: TextStyle(
            fontSize: 14, color: Colors.black38,
          )),
          const Spacer(flex: 1),
          SizedBox(
            width: double.infinity, height: 64,
            child: ElevatedButton(
              onPressed: widget.onViewOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: green, elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('View Order History', style: TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600,
              )),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
