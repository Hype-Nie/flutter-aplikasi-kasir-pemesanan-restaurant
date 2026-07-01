import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/features/customer/cart/presentation/providers/customer_cart_provider.dart';
import 'package:restaurant/features/customer/order_history/presentation/pages/customer_order_history_page.dart';
import 'package:restaurant/features/customer/payment_gateway/presentation/pages/customer_payment_gateway_page.dart';

import '../providers/customer_checkout_provider.dart';
import '../widgets/checkout_body_widgets.dart';

class CustomerCheckoutPage extends ConsumerStatefulWidget {
  const CustomerCheckoutPage({super.key});
  @override
  ConsumerState<CustomerCheckoutPage> createState() =>
      _CustomerCheckoutPageState();
}

class _CustomerCheckoutPageState
    extends ConsumerState<CustomerCheckoutPage> {
  static const _accent = Color(0xFFFF460A);
  final _tableCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _payment = 'card';
  String _orderType = 'dine_in';

  @override
  void dispose() {
    _tableCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = ref.read(customerCartProvider);
    if (cart.items.isEmpty) return;

    await ref.read(customerCheckoutProvider.notifier).createOrder(
      items: cart.items,
      totalAmount: cart.totalAmount,
      paymentMethod: _payment,
      orderType: _orderType,
      tableNumber: _orderType == 'dine_in' && _tableCtrl.text.trim().isNotEmpty
          ? _tableCtrl.text.trim() : null,
      notes: _notesCtrl.text.trim().isNotEmpty
          ? _notesCtrl.text.trim() : null,
    );

    if (!mounted) return;
    final state = ref.read(customerCheckoutProvider);
    if (state.status == CheckoutStatus.success) {
      ref.read(customerCartProvider.notifier).clearCart();
      if (_payment == 'card') {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => CustomerPaymentGatewayPage(
            paymentId: state.paymentId ?? 0,
            checkoutUrl: state.checkoutUrl ?? '',
            orderNumber: state.orderNumber ?? '',
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Order ${state.orderNumber ?? ''} placed! Pay at cashier.'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => const CustomerOrderHistoryPage(),
        ));
      }
    } else {
      _showError(state.message);
    }
  }


  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(customerCartProvider);
    final checkout = ref.watch(customerCheckoutProvider);
    final isLoading = checkout.status == CheckoutStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 18),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(
          color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600,
        )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CheckoutBody(
            cart: cart,
            accent: _accent,
            payment: _payment,
            orderType: _orderType,
            tableCtrl: _tableCtrl,
            notesCtrl: _notesCtrl,
            onPaymentChanged: (v) => setState(() => _payment = v!),
            onOrderTypeChanged: (v) => setState(() => _orderType = v!),
            onPlaceOrder: isLoading ? null : _placeOrder,
          ),
          if (isLoading) CheckoutLoadingOverlay(accent: _accent),
        ],
      ),
    );
  }
}
