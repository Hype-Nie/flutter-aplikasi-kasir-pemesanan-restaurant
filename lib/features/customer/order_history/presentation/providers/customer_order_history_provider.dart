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
  final CustomerOrderHistoryStatus detailStatus; // separate from list
  final String message;
  final List<Order> orders;
  final Order? orderDetail;
  final List<OrderItem> orderItems;
  final List<OrderItemAddon> orderItemAddons;
  final Map<int, Menu> menus;
  final Map<int, Addon> addons;

  const CustomerOrderHistoryState({
    this.status = CustomerOrderHistoryStatus.initial,
    this.detailStatus = CustomerOrderHistoryStatus.initial,
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
    CustomerOrderHistoryStatus? detailStatus,
    String? message,
    List<Order>? orders,
    Order? orderDetail,
    List<OrderItem>? orderItems,
    List<OrderItemAddon>? orderItemAddons,
    Map<int, Menu>? menus,
    Map<int, Addon>? addons,
  }) => CustomerOrderHistoryState(
    status: status ?? this.status,
    detailStatus: detailStatus ?? this.detailStatus,
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
    status, detailStatus, message, orders, orderDetail,
    orderItems, orderItemAddons, menus, addons,
  ];
}

class CustomerOrderHistoryNotifier
    extends Notifier<CustomerOrderHistoryState> {
  @override
  CustomerOrderHistoryState build() => const CustomerOrderHistoryState();

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
      detailStatus: CustomerOrderHistoryStatus.loading,
      message: '',
    );
    try {
      // Fetch order + all order-items in parallel
      final baseResults = await Future.wait([
        DioClient.instance.get('/api/orders/$orderId'),
        DioClient.instance.get('/api/order-items'),
        DioClient.instance.get('/api/order-item-addons'),
      ]);

      final order =
          Order.fromJson(baseResults[0].data as Map<String, dynamic>);

      final orderItems = _toList(baseResults[1].data)
          .map((j) => OrderItem.fromJson(j as Map<String, dynamic>))
          .where((item) => item.orderId == orderId)
          .toList();

      final orderItemIds = orderItems.map((item) => item.id).toSet();

      final allAddons = _toList(baseResults[2].data)
          .map((j) => OrderItemAddon.fromJson(j as Map<String, dynamic>))
          .toList();
      final itemAddons =
          allAddons.where((a) => orderItemIds.contains(a.orderItemId)).toList();

      // Fetch menus and addons only if we have items
      final menus = <int, Menu>{};
      final addons = <int, Addon>{};

      if (orderItems.isNotEmpty) {
        final menuIds = orderItems.map((i) => i.menuId).toSet();
        final addonIds = itemAddons.map((a) => a.addonId).toSet();

        final extraResults = await Future.wait([
          DioClient.instance.get('/api/menus'),
          if (addonIds.isNotEmpty) DioClient.instance.get('/api/addons'),
        ]);

        for (final j in _toList(extraResults[0].data)) {
          final menu = Menu.fromJson(j as Map<String, dynamic>);
          if (menuIds.contains(menu.id)) menus[menu.id] = menu;
        }

        if (addonIds.isNotEmpty && extraResults.length > 1) {
          for (final j in _toList(extraResults[1].data)) {
            final addon = Addon.fromJson(j as Map<String, dynamic>);
            if (addonIds.contains(addon.id)) addons[addon.id] = addon;
          }
        }
      }

      state = state.copyWith(
        detailStatus: CustomerOrderHistoryStatus.success,
        orderDetail: order,
        orderItems: orderItems,
        orderItemAddons: itemAddons,
        menus: menus,
        addons: addons,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        detailStatus: CustomerOrderHistoryStatus.failure,
        message: _mapError(e),
      );
    } catch (e) {
      state = state.copyWith(
        detailStatus: CustomerOrderHistoryStatus.failure,
        message: 'Error: ${e.toString()}',
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
