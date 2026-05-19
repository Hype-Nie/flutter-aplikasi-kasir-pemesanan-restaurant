import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/addon.dart';
import 'package:restaurant/shared/models/menu.dart';
import 'package:restaurant/shared/models/order.dart';
import 'package:restaurant/shared/models/order_item.dart';
import 'package:restaurant/shared/models/order_item_addon.dart';

enum CashierOrderDetailStatus { initial, loading, success, failure }

class CashierOrderDetailState extends Equatable {
  const CashierOrderDetailState({
    this.status = CashierOrderDetailStatus.initial,
    this.message = '',
    this.order,
    this.items = const [],
  });

  final CashierOrderDetailStatus status;
  final String message;
  final Order? order;
  final List<OrderItem> items;

  CashierOrderDetailState copyWith({
    CashierOrderDetailStatus? status,
    String? message,
    Order? order,
    List<OrderItem>? items,
  }) {
    return CashierOrderDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
      order: order ?? this.order,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [status, message, order, items];
}

class CashierOrderDetailNotifier extends Notifier<CashierOrderDetailState> {
  @override
  CashierOrderDetailState build() => const CashierOrderDetailState();

  Future<void> fetchOrderDetail(Order seedOrder) async {
    state = state.copyWith(
      status: CashierOrderDetailStatus.loading,
      message: '',
      order: seedOrder,
      items: const [],
    );

    try {
      final results = await Future.wait<dynamic>([
        DioClient.instance.get('/api/orders/${seedOrder.id}'),
        _fetchListFromCandidates(['/api/order-items', '/api/order_items']),
        _fetchListFromCandidates([
          '/api/order-item-addons',
          '/api/order_item_addons',
        ]),
        _fetchListFromCandidates(['/api/menus']),
        _fetchListFromCandidates(['/api/addons']),
      ]);

      final orderResponse = results[0] as Response<dynamic>;
      final orderItemsRaw = results[1] as List<dynamic>;
      final itemAddonsRaw = results[2] as List<dynamic>;
      final menusRaw = results[3] as List<dynamic>;
      final addonsRaw = results[4] as List<dynamic>;

      final order = Order.fromJson(_asMap(orderResponse.data));

      final orderItems = orderItemsRaw
          .map((e) => OrderItem.fromJson(_asMap(e)))
          .where((item) => item.orderId == order.id)
          .toList();

      final allItemAddons = itemAddonsRaw
          .map((e) => OrderItemAddon.fromJson(_asMap(e)))
          .toList();

      final menuById = <int, Menu>{};
      for (final raw in menusRaw) {
        final menu = Menu.fromJson(_asMap(raw));
        menuById[menu.id] = menu;
      }

      final addonById = <int, Addon>{};
      for (final raw in addonsRaw) {
        final addon = Addon.fromJson(_asMap(raw));
        addonById[addon.id] = addon;
      }

      final itemIdSet = orderItems.map((e) => e.id).toSet();
      final addonsByItemId = <int, List<OrderItemAddon>>{};
      for (final addon in allItemAddons) {
        if (!itemIdSet.contains(addon.orderItemId)) continue;
        final addonName = addonById[addon.addonId]?.name ?? addon.addonName;
        final enriched = addon.copyWith(addonName: addonName);
        addonsByItemId.putIfAbsent(addon.orderItemId, () => []).add(enriched);
      }

      final enrichedItems = orderItems.map((item) {
        final resolvedName = menuById[item.menuId]?.name ?? item.menuName;
        final itemAddons = addonsByItemId[item.id] ?? const <OrderItemAddon>[];
        return item.copyWith(menuName: resolvedName, addons: itemAddons);
      }).toList();

      state = state.copyWith(
        status: CashierOrderDetailStatus.success,
        order: order.copyWith(items: enrichedItems),
        items: enrichedItems,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierOrderDetailStatus.failure,
        message: _mapError(e),
      );
    } catch (e, stackTrace) {
      debugPrint('[CashierOrderDetail] unexpected error: $e');
      debugPrint('[CashierOrderDetail] stackTrace: $stackTrace');
      state = state.copyWith(
        status: CashierOrderDetailStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  Future<List<dynamic>> _fetchListFromCandidates(List<String> paths) async {
    DioException? lastError;
    for (final path in paths) {
      try {
        final response = await DioClient.instance.get(path);
        return _asList(response.data);
      } on DioException catch (e) {
        lastError = e;
      }
    }
    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: paths.first),
          message: CashierStrings.fetchError,
        );
  }

  List<dynamic> _asList(dynamic raw) {
    if (raw is List<dynamic>) return raw;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List<dynamic>) return data;
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return <String, dynamic>{};
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

final cashierOrderDetailProvider =
    NotifierProvider<CashierOrderDetailNotifier, CashierOrderDetailState>(
      CashierOrderDetailNotifier.new,
    );
