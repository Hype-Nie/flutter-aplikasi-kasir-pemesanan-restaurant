import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/customer/domain/entities/addon.dart';
import 'package:restaurant/features/customer/domain/entities/menu.dart';
import 'package:restaurant/features/customer/domain/entities/order.dart';
import 'package:restaurant/features/customer/domain/entities/order_item.dart';

enum CustomerOrderHistoryStatus { initial, loading, success, failure }

class CustomerOrderHistoryState extends Equatable {
  final CustomerOrderHistoryStatus status;
  final String message;
  final List<Order> orders;
  final Order? orderDetail;
  final List<OrderItem> orderItems;
  final List<OrderItemAddon> orderItemAddons;
  final Map<int, Menu> menus;
  final Map<int, Addon> addons;

  const CustomerOrderHistoryState({
    this.status = CustomerOrderHistoryStatus.initial,
    this.message = '',
    this.orders = const [],
    this.orderDetail,
    this.orderItems = const [],
    this.orderItemAddons = const [],
    this.menus = const {},
    this.addons = const {},
  });

  CustomerOrderHistoryState copyWith({
    CustomerOrderHistoryStatus? status,
    String? message,
    List<Order>? orders,
    Order? orderDetail,
    List<OrderItem>? orderItems,
    List<OrderItemAddon>? orderItemAddons,
    Map<int, Menu>? menus,
    Map<int, Addon>? addons,
  }) => CustomerOrderHistoryState(
    status: status ?? this.status,
    message: message ?? this.message,
    orders: orders ?? this.orders,
    orderDetail: orderDetail ?? this.orderDetail,
    orderItems: orderItems ?? this.orderItems,
    orderItemAddons: orderItemAddons ?? this.orderItemAddons,
    menus: menus ?? this.menus,
    addons: addons ?? this.addons,
  );

  @override
  List<Object?> get props => [
    status, message, orders, orderDetail,
    orderItems, orderItemAddons, menus, addons,
  ];
}

class CustomerOrderHistoryNotifier
    extends Notifier<CustomerOrderHistoryState> {
  @override
  CustomerOrderHistoryState build() => const CustomerOrderHistoryState();

  // Safely extract a List from any response shape
  List<dynamic> _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return [];
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(
      status: CustomerOrderHistoryStatus.loading,
      message: '',
    );
    try {
      final userId = await TokenStorage.getUserId();
      final response = await DioClient.instance.get('/api/orders');
      final data = _toList(response.data);
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
    state = state.copyWith(
      status: CustomerOrderHistoryStatus.loading,
      message: '',
    );
    try {
      final results = await Future.wait([
        DioClient.instance.get('/api/orders/$orderId'),
        DioClient.instance.get('/api/order-items'),
        DioClient.instance.get('/api/order-item-addons'),
        DioClient.instance.get('/api/menus'),
        DioClient.instance.get('/api/addons'),
      ]);

      final order =
          Order.fromJson(results[0].data as Map<String, dynamic>);

      final orderItems = _toList(results[1].data)
          .map((j) => OrderItem.fromJson(j as Map<String, dynamic>))
          .where((item) => item.orderId == orderId)
          .toList();

      final allItemAddons = _toList(results[2].data)
          .map((j) => OrderItemAddon.fromJson(j as Map<String, dynamic>))
          .toList();

      final orderItemIds = orderItems.map((item) => item.id).toSet();
      final itemAddons =
          allItemAddons.where((a) => orderItemIds.contains(a.orderItemId)).toList();

      final menus = <int, Menu>{};
      for (final json in _toList(results[3].data)) {
        final menu = Menu.fromJson(json as Map<String, dynamic>);
        menus[menu.id] = menu;
      }

      final addons = <int, Addon>{};
      for (final json in _toList(results[4].data)) {
        final addon = Addon.fromJson(json as Map<String, dynamic>);
        addons[addon.id] = addon;
      }

      state = state.copyWith(
        status: CustomerOrderHistoryStatus.success,
        orderDetail: order,
        orderItems: orderItems,
        orderItemAddons: itemAddons,
        menus: menus,
        addons: addons,
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
