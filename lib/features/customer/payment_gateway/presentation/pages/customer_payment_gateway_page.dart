import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  WebViewController? _webCtrl;
  bool _webReady = false;
  bool _showWebView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWebView();
      ref
          .read(customerPaymentGatewayProvider.notifier)
          .startPolling(widget.paymentId);
    });
  }

  void _initWebView() {
    if (widget.checkoutUrl.isEmpty) return;
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _webReady = false),
        onPageFinished: (_) => setState(() => _webReady = true),
        onWebResourceError: (_) => setState(() => _webReady = true),
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));
    setState(() {
      _webCtrl = ctrl;
      _showWebView = true;
    });
  }

  void _goToOrderHistory() {
    ref.read(customerPaymentGatewayProvider.notifier).reset();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _goBackToCart() {
    ref.read(customerPaymentGatewayProvider.notifier).reset();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerPaymentGatewayProvider);
    final payment = state.payment;

    final isPaid = payment?.isPaid ?? false;
    final isFailed = payment?.isFailed ?? false;
    final isExpired = payment?.isExpired ?? false;
    final isDone = isPaid || isFailed || isExpired;

    return PopScope(
      canPop: isDone,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F8),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          automaticallyImplyLeading: false,
          title: Text(
            isDone ? 'Payment' : 'Complete Payment',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            if (!isDone && _webCtrl != null)
              TextButton(
                onPressed: () =>
                    setState(() => _showWebView = !_showWebView),
                child: Text(
                  _showWebView ? 'Status' : 'Pay',
                  style: const TextStyle(color: Color(0xFFFF460A)),
                ),
              ),
          ],
        ),
        body: _buildBody(isPaid, isFailed, isExpired),
      ),
    );
  }

  Widget _buildBody(bool isPaid, bool isFailed, bool isExpired) {
    if (isPaid) {
      return PaymentSuccessView(
        orderNumber: widget.orderNumber,
        onViewOrder: _goToOrderHistory,
      );
    }
    if (isFailed || isExpired) {
      return PaymentFailedView(
        isExpired: isExpired,
        onRetry: () => setState(() => _showWebView = true),
        onBackToCart: _goBackToCart,
      );
    }

    // Pending — show WebView or status card
    final ctrl = _webCtrl;
    if (_showWebView && ctrl != null) {
      return Stack(children: [
        WebViewWidget(controller: ctrl),
        if (!_webReady)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF460A)),
          ),
      ]);
    }

    return PaymentPendingView(
      onOpenPayment: () => setState(() => _showWebView = true),
    );
  }
}
