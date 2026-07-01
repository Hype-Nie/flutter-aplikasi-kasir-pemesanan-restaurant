import 'package:flutter/material.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/checkout_option_cards.dart';

class CheckoutBody extends StatelessWidget {
  final CustomerCartState cart;
  final Color accent;
  final String payment;
  final String orderType;
  final TextEditingController tableCtrl;
  final TextEditingController notesCtrl;
  final ValueChanged<String?> onPaymentChanged;
  final ValueChanged<String?> onOrderTypeChanged;
  final VoidCallback? onPlaceOrder;

  const CheckoutBody({
    super.key, required this.cart, required this.accent,
    required this.payment, required this.orderType,
    required this.tableCtrl, required this.notesCtrl,
    required this.onPaymentChanged, required this.onOrderTypeChanged,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Order Summary',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          CheckoutOrderSummary(items: cart.items, accent: accent),
          const SizedBox(height: 24),
          const Text('Order Type',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          OrderTypeCard(orderType: orderType, onChanged: onOrderTypeChanged),
          const SizedBox(height: 24),
          AnimatedCrossFade(
            firstChild: _DineInFields(
                tableCtrl: tableCtrl, notesCtrl: notesCtrl),
            secondChild: _NotesOnly(notesCtrl: notesCtrl),
            crossFadeState: orderType == 'dine_in'
                ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
          const SizedBox(height: 24),
          const Text('Payment Method',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          PaymentMethodCard(payment: payment, onChanged: onPaymentChanged),
          const SizedBox(height: 28),
          CheckoutPriceBreakdown(total: cart.totalAmount, accent: accent),
          const SizedBox(height: 28),
          _PlaceOrderBtn(accent: accent, onPressed: onPlaceOrder),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DineInFields extends StatelessWidget {
  final TextEditingController tableCtrl, notesCtrl;
  const _DineInFields({required this.tableCtrl, required this.notesCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Table & Notes',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      CheckoutNotesField(
          tableController: tableCtrl, notesController: notesCtrl),
    ]);
  }
}

class _NotesOnly extends StatelessWidget {
  final TextEditingController notesCtrl;
  const _NotesOnly({required this.notesCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Notes',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      TextField(
        controller: notesCtrl, maxLines: 2,
        decoration: InputDecoration(
          hintText: 'Notes (optional)',
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
          prefixIcon: const Icon(Icons.notes_outlined,
              color: Colors.black38, size: 20),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        ),
      ),
    ]);
  }
}

class _PlaceOrderBtn extends StatelessWidget {
  final Color accent;
  final VoidCallback? onPressed;
  const _PlaceOrderBtn({required this.accent, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accent, elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30))),
        child: const Text('Place Order & Pay', style: TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class CheckoutLoadingOverlay extends StatelessWidget {
  final Color accent;
  const CheckoutLoadingOverlay({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black26,
      child: Center(child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 48, height: 48,
            child: CircularProgressIndicator(strokeWidth: 3, color: accent)),
          const SizedBox(height: 16),
          const Text('Creating your order...', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      )),
    );
  }
}
