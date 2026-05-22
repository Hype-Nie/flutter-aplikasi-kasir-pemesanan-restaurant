import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/order.dart';

enum CashierOrderStatusManagementStatus { initial, loading, success, failure }

class CashierOrderStatusManagementState extends Equatable {
  const CashierOrderStatusManagementState({
    this.status = CashierOrderStatusManagementStatus.initial,
    this.message = '',
    this.orders = const [],
  });

  final CashierOrderStatusManagementStatus status;
  final String message;
  final List<Order> orders;

  CashierOrderStatusManagementState copyWith({
    CashierOrderStatusManagementStatus? status,
    String? message,
    List<Order>? orders,
  }) {
    return CashierOrderStatusManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [status, message, orders];
}

class CashierOrderStatusManagementNotifier
    extends Notifier<CashierOrderStatusManagementState> {
  @override
  CashierOrderStatusManagementState build() =>
      const CashierOrderStatusManagementState();

  Future<void> fetchOrders() async {
    state = state.copyWith(
      status: CashierOrderStatusManagementStatus.loading,
      message: '',
    );

    try {
      final response = await DioClient.instance.get('/api/orders');
      final data = response.data as List<dynamic>;
      final allOrders = data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

        // Filter for status flow orders only (accepted/preparing/ready/served)
        final activeOrders = allOrders
          .where(
          (o) =>
            o.status == 'accepted' ||
            o.status == 'preparing' ||
            o.status == 'ready' ||
            o.status == 'served',
          )
          .toList();

      state = state.copyWith(
        status: CashierOrderStatusManagementStatus.success,
        orders: activeOrders,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierOrderStatusManagementStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: CashierOrderStatusManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  Future<bool> updateOrderStatus(int id, String newStatus) async {
    state = state.copyWith(
      status: CashierOrderStatusManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.put(
        '/api/orders/$id',
        data: {'status': newStatus},
      );

      state = state.copyWith(
        status: CashierOrderStatusManagementStatus.success,
        message: CashierStrings.orderStatusUpdated,
      );

      await fetchOrders();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierOrderStatusManagementStatus.failure,
        message: _mapError(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierOrderStatusManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
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

final cashierOrderStatusManagementProvider =
    NotifierProvider<
      CashierOrderStatusManagementNotifier,
      CashierOrderStatusManagementState
    >(CashierOrderStatusManagementNotifier.new);
