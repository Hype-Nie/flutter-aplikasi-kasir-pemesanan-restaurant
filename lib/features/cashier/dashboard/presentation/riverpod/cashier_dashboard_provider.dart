import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/shared/models/order.dart';

enum CashierDashboardStatus { initial, loading, success, failure }

class CashierDashboardState extends Equatable {
  const CashierDashboardState({
    this.status = CashierDashboardStatus.initial,
    this.message = '',
    this.orders = const [],
    this.userName = 'Cashier',
  });

  final CashierDashboardStatus status;
  final String message;
  final List<Order> orders;
  final String userName;

  List<Order> get pendingOrders =>
      orders.where((o) => o.status == 'pending').toList();

  List<Order> get activeOrders => orders
      .where(
      (o) =>
        o.status == 'accepted' ||
        o.status == 'preparing' ||
        o.status == 'ready' ||
        o.status == 'served',
      )
      .toList();

  List<Order> get completedOrders =>
      orders.where((o) => o.status == 'completed').toList();

  List<Order> get cancelledOrders =>
      orders.where((o) => o.status == 'cancelled').toList();

  List<Order> get historyOrders => orders
      .where((o) => o.status == 'completed' || o.status == 'cancelled')
      .toList();

  double get totalRevenue =>
      completedOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

  CashierDashboardState copyWith({
    CashierDashboardStatus? status,
    String? message,
    List<Order>? orders,
    String? userName,
  }) {
    return CashierDashboardState(
      status: status ?? this.status,
      message: message ?? this.message,
      orders: orders ?? this.orders,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [status, message, orders, userName];
}

class CashierDashboardNotifier extends Notifier<CashierDashboardState> {
  @override
  CashierDashboardState build() => const CashierDashboardState();

  Future<void> fetchOrders() async {
    state = state.copyWith(status: CashierDashboardStatus.loading, message: '');

    try {
      final results = await Future.wait([
        DioClient.instance.get('/api/orders'),
        TokenStorage.getName(),
      ]);
      final response = results[0] as Response;
      final savedName = results[1] as String?;
      final data = response.data as List<dynamic>;
      final orders = data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: CashierDashboardStatus.success,
        orders: orders,
        userName: savedName ?? 'Cashier',
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierDashboardStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: CashierDashboardStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  Future<bool> updateOrderStatus(int id, String newStatus) async {
    state = state.copyWith(status: CashierDashboardStatus.loading, message: '');

    try {
      await DioClient.instance.put(
        '/api/orders/$id',
        data: {'status': newStatus},
      );

      state = state.copyWith(
        status: CashierDashboardStatus.success,
        message: CashierStrings.orderStatusUpdated,
      );

      await fetchOrders();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierDashboardStatus.failure,
        message: _mapError(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierDashboardStatus.failure,
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
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return CashierStrings.orderFetchError;
  }
}

final cashierDashboardProvider =
    NotifierProvider<CashierDashboardNotifier, CashierDashboardState>(
      CashierDashboardNotifier.new,
    );
