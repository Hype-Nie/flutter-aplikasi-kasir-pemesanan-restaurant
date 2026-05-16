import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/features/customer/domain/entities/addon.dart';

enum CustomerMenuDetailStatus { initial, loading, success, failure }

class CustomerMenuDetailState extends Equatable {
  final CustomerMenuDetailStatus status;
  final String message;
  final List<MenuAddon> addons;

  const CustomerMenuDetailState({
    this.status = CustomerMenuDetailStatus.initial,
    this.message = '',
    this.addons = const [],
  });

  CustomerMenuDetailState copyWith({
    CustomerMenuDetailStatus? status,
    String? message,
    List<MenuAddon>? addons,
  }) =>
      CustomerMenuDetailState(
        status: status ?? this.status,
        message: message ?? this.message,
        addons: addons ?? this.addons,
      );

  @override
  List<Object?> get props => [status, message, addons];
}

class MenuAddon extends Equatable {
  final int id;
  final String name;
  final String price;

  const MenuAddon({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  List<Object?> get props => [id, name, price];
}

class CustomerMenuDetailNotifier extends Notifier<CustomerMenuDetailState> {
  @override
  CustomerMenuDetailState build() => const CustomerMenuDetailState();

  Future<void> fetchMenuAddons(int menuId) async {
    state = const CustomerMenuDetailState(status: CustomerMenuDetailStatus.loading);

    try {
      final results = await Future.wait([
        DioClient.instance.get('/api/menu-addons'),
        DioClient.instance.get('/api/addons'),
      ]);

      final addonMap = <int, Addon>{};
      for (final json in results[1].data as List<dynamic>) {
        final a = Addon.fromJson(json as Map<String, dynamic>);
        addonMap[a.id] = a;
      }

      final menuAddons = (results[0].data as List<dynamic>)
          .map((json) => json as Map<String, dynamic>)
          .where((m) => m['menu_id'].toString() == menuId.toString())
          .map((m) {
            final addonId = int.tryParse(m['addon_id'].toString()) ?? 0;
            final a = addonMap[addonId];
            return MenuAddon(
              id: m['id'] as int,
              name: a?.name ?? 'Addon #${m['addon_id']}',
              price: a?.price ?? '0',
            );
          })
          .toList();

      state = state.copyWith(
        status: CustomerMenuDetailStatus.success,
        addons: menuAddons,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to load addons.';
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) msg = message;
      }
      state = state.copyWith(status: CustomerMenuDetailStatus.failure, message: msg);
    } catch (_) {
      state = state.copyWith(
        status: CustomerMenuDetailStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }
}

final customerMenuDetailProvider =
    NotifierProvider<CustomerMenuDetailNotifier, CustomerMenuDetailState>(
        CustomerMenuDetailNotifier.new);
