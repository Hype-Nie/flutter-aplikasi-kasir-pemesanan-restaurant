import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/customer/domain/entities/order.dart';

enum CustomerOrderHistoryStatus { initial, loading, success, failure }

class CustomerOrderHistoryState extends Equatable {
  final CustomerOrderHistoryStatus status;
  final String message;
  final List<Order> orders;
  final Order? orderDetail;

  const CustomerOrderHistoryState({
    this.status = CustomerOrderHistoryStatus.initial,
    this.message = '',
    this.orders = const [],
    this.orderDetail,
  });

  CustomerOrderHistoryState copyWith({
    CustomerOrderHistoryStatus? status,
    String? message,
    List<Order>? orders,
    Order? orderDetail,
  }) =>
      CustomerOrderHistoryState(
        status: status ?? this.status,
        message: message ?? this.message,
        orders: orders ?? this.orders,
        orderDetail: orderDetail ?? this.orderDetail,
      );

  @override
  List<Object?> get props => [status, message, orders, orderDetail];
}

class CustomerOrderHistoryNotifier extends Notifier<CustomerOrderHistoryState> {
  @override
  CustomerOrderHistoryState build() => const CustomerOrderHistoryState();

  Future<void> fetchOrders() async {
    state = state.copyWith(status: CustomerOrderHistoryStatus.loading, message: '');

    try {
      final response = await DioClient.instance.get('/api/orders');
      final userId = await TokenStorage.getUserId();
      final data = response.data as List<dynamic>;
      final orders = data
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .where((o) => userId == null || o.userId == userId)
          .toList();

      state = state.copyWith(
        status: CustomerOrderHistoryStatus.success,
        orders: orders,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CustomerOrderHistoryStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: CustomerOrderHistoryStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }

  Future<void> fetchOrderDetail(int orderId) async {
    state = state.copyWith(status: CustomerOrderHistoryStatus.loading, message: '');

    try {
      final response = await DioClient.instance.get('/api/orders/$orderId');
      final order = Order.fromJson(response.data as Map<String, dynamic>);

      state = state.copyWith(
        status: CustomerOrderHistoryStatus.success,
        orderDetail: order,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CustomerOrderHistoryStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: CustomerOrderHistoryStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }

  String _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Failed to load orders.';
  }
}

final customerOrderHistoryProvider = NotifierProvider<
    CustomerOrderHistoryNotifier, CustomerOrderHistoryState>(
  CustomerOrderHistoryNotifier.new,
);
