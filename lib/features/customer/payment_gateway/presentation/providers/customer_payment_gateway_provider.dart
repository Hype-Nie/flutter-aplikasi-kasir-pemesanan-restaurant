import 'dart:async';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/features/customer/domain/entities/payment.dart';

enum PaymentGatewayStatus { initial, loading, success, failure }

class PaymentGatewayState extends Equatable {
  final PaymentGatewayStatus status;
  final String message;
  final Payment? payment;

  const PaymentGatewayState({
    this.status = PaymentGatewayStatus.initial,
    this.message = '',
    this.payment,
  });

  PaymentGatewayState copyWith({
    PaymentGatewayStatus? status,
    String? message,
    Payment? payment,
  }) => PaymentGatewayState(
    status: status ?? this.status,
    message: message ?? this.message,
    payment: payment ?? this.payment,
  );

  @override
  List<Object?> get props => [status, message, payment];
}

class PaymentGatewayNotifier extends Notifier<PaymentGatewayState> {
  Timer? _pollTimer;

  @override
  PaymentGatewayState build() => const PaymentGatewayState();

  Future<void> checkPaymentStatus(int paymentId) async {
    if (paymentId == 0) return;
    state = state.copyWith(
      status: PaymentGatewayStatus.loading,
      message: '',
    );
    try {
      final res = await DioClient.instance.get('/api/payments/$paymentId');
      final payment = Payment.fromJson(res.data as Map<String, dynamic>);
      state = state.copyWith(
        status: PaymentGatewayStatus.success,
        payment: payment,
      );
      if (payment.isPaid || payment.isFailed || payment.isExpired) {
        stopPolling();
      }
    } on DioException catch (e) {
      state = state.copyWith(
        status: PaymentGatewayStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: PaymentGatewayStatus.failure,
        message: 'Failed to check payment status.',
      );
    }
  }

  void startPolling(int paymentId) {
    stopPolling();
    checkPaymentStatus(paymentId);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkPaymentStatus(paymentId),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void reset() {
    stopPolling();
    state = const PaymentGatewayState();
  }

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'];
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Network error. Please check your connection.';
    }
    return 'Failed to check payment status.';
  }
}

final customerPaymentGatewayProvider =
    NotifierProvider<PaymentGatewayNotifier, PaymentGatewayState>(
      PaymentGatewayNotifier.new,
    );
