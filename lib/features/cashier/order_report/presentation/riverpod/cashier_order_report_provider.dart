import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/order.dart';

enum CashierOrderReportStatus { initial, loading, success, failure }

class CashierOrderReportState extends Equatable {
  const CashierOrderReportState({
    this.status = CashierOrderReportStatus.initial,
    this.message = '',
    this.orders = const [],
  });

  final CashierOrderReportStatus status;
  final String message;
  final List<Order> orders;

  List<Order> get completedOrders =>
      orders.where((o) => o.status == 'completed').toList();

  List<Order> get cancelledOrders =>
      orders.where((o) => o.status == 'cancelled').toList();

  double get totalRevenue =>
      completedOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

  /// Group orders by day-of-week (Mon=1..Sun=7) for chart data
  Map<int, double> get revenueByWeekday {
    final map = <int, double>{};
    for (final o in completedOrders) {
      if (o.createdAt != null) {
        final wd = o.createdAt!.toLocal().weekday;
        map[wd] = (map[wd] ?? 0) + o.totalAmount;
      }
    }
    return map;
  }

  /// Top selling items from order items
  Map<String, int> get topSellingItems {
    final map = <String, int>{};
    for (final o in completedOrders) {
      for (final item in o.items) {
        map[item.menuName] = (map[item.menuName] ?? 0) + item.quantity;
      }
    }
    // Sort by quantity descending
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  CashierOrderReportState copyWith({
    CashierOrderReportStatus? status,
    String? message,
    List<Order>? orders,
  }) {
    return CashierOrderReportState(
      status: status ?? this.status,
      message: message ?? this.message,
      orders: orders ?? this.orders,
    );
  }

  @override
  List<Object?> get props => [status, message, orders];
}

class CashierOrderReportNotifier extends Notifier<CashierOrderReportState> {
  @override
  CashierOrderReportState build() => const CashierOrderReportState();

  Future<void> fetchReport() async {
    state = state.copyWith(
      status: CashierOrderReportStatus.loading,
      message: '',
    );

    try {
      final response = await DioClient.instance.get('/api/orders');
      final data = response.data as List<dynamic>;
      final orders =
          data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();

      state = state.copyWith(
        status: CashierOrderReportStatus.success,
        orders: orders,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierOrderReportStatus.failure,
        message: _mapError(e),
      );
    } catch (_) {
      state = state.copyWith(
        status: CashierOrderReportStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  void started() => fetchReport();

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

final cashierOrderReportProvider =
    NotifierProvider<CashierOrderReportNotifier, CashierOrderReportState>(
      CashierOrderReportNotifier.new,
    );
