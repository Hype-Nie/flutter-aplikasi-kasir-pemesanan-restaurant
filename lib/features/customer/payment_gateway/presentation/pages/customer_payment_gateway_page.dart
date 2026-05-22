import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restaurant/features/customer/cart/presentation/pages/customer_cart_page.dart';
import 'package:restaurant/features/customer/order_history/presentation/pages/customer_order_history_page.dart';

import '../providers/customer_payment_gateway_provider.dart';
import '../widgets/payment_failed_widget.dart';
import '../widgets/payment_status_widgets.dart';

class CustomerPaymentGatewayPage extends ConsumerStatefulWidget {
  final int paymentId;
  final String checkoutUrl;
  final String orderNumber;

  const CustomerPaymentGatewayPage({
    super.key,
    required this.paymentId,
    required this.checkoutUrl,
    required this.orderNumber,
  });

  @override
  ConsumerState<CustomerPaymentGatewayPage> createState() =>
      _PaymentGatewayPageState();
}

class _PaymentGatewayPageState
    extends ConsumerState<CustomerPaymentGatewayPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerPaymentGatewayProvider.notifier)
          .startPolling(widget.paymentId);
    });
  }

  @override
  void dispose() {
    // Notifier handles timer cleanup via reset/stopPolling
    super.dispose();
  }

  void _openPayment() async {
    final uri = Uri.tryParse(widget.checkoutUrl);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _goToOrderHistory() {
    ref.read(customerPaymentGatewayProvider.notifier).reset();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerOrderHistoryPage(),
      ),
      (route) => route.isFirst,
    );
  }

  void _goBackToCart() {
    ref.read(customerPaymentGatewayProvider.notifier).reset();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerCartPage()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerPaymentGatewayProvider);
    final payment = state.payment;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: false,
          title: const Text('Payment', style: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600,
          )),
          centerTitle: true,
        ),
        body: _buildBody(state, payment),
      ),
    );
  }

  Widget _buildBody(PaymentGatewayState state, dynamic payment) {
    if (payment != null && payment.isPaid) {
      return PaymentSuccessView(
        orderNumber: widget.orderNumber,
        onViewOrder: _goToOrderHistory,
      );
    }
    if (payment != null && (payment.isFailed || payment.isExpired)) {
      return PaymentFailedView(
        isExpired: payment.isExpired,
        onRetry: _openPayment,
        onBackToCart: _goBackToCart,
      );
    }
    return PaymentPendingView(onOpenPayment: _openPayment);
  }
}
