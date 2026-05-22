import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/customer/cart/domain/entities/cart_item.dart';

enum CheckoutStatus { initial, loading, success, failure }

class CheckoutState extends Equatable {
  final CheckoutStatus status;
  final String message;
  final int? orderId;
  final String? orderNumber;
  final int? paymentId;
  final String? checkoutUrl;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.message = '',
    this.orderId,
    this.orderNumber,
    this.paymentId,
    this.checkoutUrl,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? message,
    int? orderId,
    String? orderNumber,
    int? paymentId,
    String? checkoutUrl,
  }) => CheckoutState(
    status: status ?? this.status,
    message: message ?? this.message,
    orderId: orderId ?? this.orderId,
    orderNumber: orderNumber ?? this.orderNumber,
    paymentId: paymentId ?? this.paymentId,
    checkoutUrl: checkoutUrl ?? this.checkoutUrl,
  );

  @override
  List<Object?> get props => [
    status, message, orderId, orderNumber, paymentId, checkoutUrl,
  ];
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  Future<void> createOrder({
    required List<CartItem> items,
    required String totalAmount,
    required String paymentMethod,
    required String orderType,
    String? tableNumber,
    String? notes,
  }) async {
    state = const CheckoutState(status: CheckoutStatus.loading);
    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        state = state.copyWith(
          status: CheckoutStatus.failure,
          message: 'User not found.',
        );
        return;
      }

      // Validate table number for dine_in
      if (orderType == 'dine_in' &&
          (tableNumber == null || tableNumber.trim().isEmpty)) {
        state = state.copyWith(
          status: CheckoutStatus.failure,
          message: 'Table number is required for Dine In.',
        );
        return;
      }

      // 1. Generate sequential order_number
      final ordersRes = await DioClient.instance.get('/api/orders');
      final rawData = ordersRes.data;
      int ordersCount;
      if (rawData is List) {
        ordersCount = rawData.length;
      } else if (rawData is Map && rawData['data'] is List) {
        ordersCount = (rawData['data'] as List).length;
      } else {
        ordersCount = 0;
      }
      final orderNum = '#${ordersCount + 1}';

      // 2. Create order
      final orderRes = await DioClient.instance.post('/api/orders', data: {
        'order_number': orderNum,
        'user_id': userId,
        'order_type': orderType,
        'table_number': orderType == 'dine_in' ? (tableNumber ?? '') : '',
        'payment_method': paymentMethod,
        'delivery_method':
            orderType == 'take_away' ? 'pick_up' : 'door_delivery',
        'total_amount': totalAmount,
        'notes': notes ?? '',
      });
      final orderData = orderRes.data as Map<String, dynamic>;
      final orderId = orderData['id'] as int;
      final orderNumber = orderData['order_number'] as String? ?? orderNum;

      // 3. Create order items in parallel
      final itemFutures = items.map((item) =>
        DioClient.instance.post('/api/order-items', data: {
          'order_id': orderId,
          'menu_id': item.menuId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
        }),
      );
      final itemResults = await Future.wait(itemFutures);

      // 4. Create order item addons in parallel
      final addonFutures = <Future>[];
      for (var i = 0; i < items.length; i++) {
        final orderItemData = itemResults[i].data as Map<String, dynamic>;
        final orderItemId = orderItemData['id'] as int;
        for (final addon in items[i].addons) {
          addonFutures.add(
            DioClient.instance.post('/api/order-item-addons', data: {
              'order_item_id': orderItemId,
              'addon_id': addon.addonId,
              'addon_price': addon.addonPrice,
            }),
          );
        }
      }
      if (addonFutures.isNotEmpty) await Future.wait(addonFutures);

      // 5. Xendit checkout — only for card payment
      if (paymentMethod == 'card') {
        // Fetch user email for Xendit payer_email
        String payerEmail = 'customer@restaurant.com';
        try {
          final userRes =
              await DioClient.instance.get('/api/users/$userId');
          final userData = userRes.data as Map<String, dynamic>;
          payerEmail = userData['email'] as String? ?? payerEmail;
        } catch (_) {}

        final paymentRes = await DioClient.instance.post(
          '/api/payments/xendit/checkout',
          data: {
            'order_id': orderId,
            'success_redirect_url': 'https://example.com/success',
            'failure_redirect_url': 'https://example.com/failed',
            'payer_email': payerEmail,
            'description': 'Order $orderNumber',
            'invoice_duration': 86400,
          },
        );
        final payData = paymentRes.data as Map<String, dynamic>;
        state = state.copyWith(
          status: CheckoutStatus.success,
          orderId: orderId,
          orderNumber: orderNumber,
          paymentId: payData['id'] as int?,
          checkoutUrl: payData['checkout_url'] as String? ??
              payData['invoice_url'] as String? ?? '',
        );
      } else {
        // Cash — no payment gateway needed
        state = state.copyWith(
          status: CheckoutStatus.success,
          orderId: orderId,
          orderNumber: orderNumber,
          paymentId: null,
          checkoutUrl: '',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        message: _mapError(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.failure,
        message: 'Something went wrong: ${e.toString()}',
      );
    }
  }

  void reset() => state = const CheckoutState();

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        return (errors.values.first as List).first.toString();
      }
      if (data['message'] is String) return data['message'];
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Network error. Please check your connection.';
    }
    return 'Failed to create order.';
  }
}

final customerCheckoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);
