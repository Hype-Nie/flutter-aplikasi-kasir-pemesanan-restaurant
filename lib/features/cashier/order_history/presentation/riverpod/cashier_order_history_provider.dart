import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/order.dart';

enum CashierOrderHistoryStatus { initial, loading, success, failure }

class CashierOrderHistoryState extends Equatable {
  const CashierOrderHistoryState({
    this.status = CashierOrderHistoryStatus.initial,
    this.message = '',
    this.orders = const [],
  });

  final CashierOrderHistoryStatus status;
  final String message;
  final List<Order> orders;

  CashierOrderHistoryState copyWith({
    CashierOrderHistoryStatus? status,
    String? message,
    List<Order>? orders,
  }) {
    return CashierOrderHistoryState(
      status: status ?? this.status,
      message: message ?? this.message,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [status, message, orders];
}

class CashierOrderHistoryNotifier extends Notifier<CashierOrderHistoryState> {
  @override
  CashierOrderHistoryState build() => const CashierOrderHistoryState();

  Future<void> fetchOrderHistory() async {
    state = state.copyWith(
      status: CashierOrderHistoryStatus.loading,
      message: '',
    );

    try {
      final response = await DioClient.instance.get('/api/orders');
      final data = response.data as List<dynamic>;
      final allOrders =
          data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();

      // Filter for completed/cancelled orders
      final historyOrders = allOrders
          .where((o) =>
              o.status == 'completed' || o.status == 'cancelled')
          .toList();

      state = state.copyWith(
        status: CashierOrderHistoryStatus.success,
        orders: historyOrders,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierOrderHistoryStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: CashierOrderHistoryStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return CashierStrings.networkError;
    }
    final data = e.response?.data;
    if (data is Map) {
      if (e.response?.statusCode == 422) {
        final errors = data['errors'];
        if (errors is Map) {
          final first = errors.values.first;
          return first is List ? first.first.toString() : first.toString();
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return CashierStrings.orderFetchError;
  }
}

final cashierOrderHistoryProvider =
    NotifierProvider<CashierOrderHistoryNotifier, CashierOrderHistoryState>(
      CashierOrderHistoryNotifier.new,
    );
