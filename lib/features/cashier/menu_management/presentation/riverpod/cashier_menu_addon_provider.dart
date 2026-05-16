import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/menu_addon.dart';

enum CashierMenuAddonStatus { initial, loading, success, failure }

class CashierMenuAddonState extends Equatable {
  const CashierMenuAddonState({
    this.status = CashierMenuAddonStatus.initial,
    this.message = '',
    this.menuAddons = const [],
  });

  final CashierMenuAddonStatus status;
  final String message;
  final List<MenuAddon> menuAddons;

  CashierMenuAddonState copyWith({
    CashierMenuAddonStatus? status,
    String? message,
    List<MenuAddon>? menuAddons,
  }) {
    return CashierMenuAddonState(
      status: status ?? this.status,
      message: message ?? this.message,
      menuAddons: menuAddons ?? this.menuAddons,
    );
  }

  @override
  List<Object?> get props => [status, message, menuAddons];
}

class CashierMenuAddonNotifier extends Notifier<CashierMenuAddonState> {
  @override
  CashierMenuAddonState build() => const CashierMenuAddonState();

  Future<bool> createMenuAddon(int menuId, int addonId) async {
    state = state.copyWith(
      status: CashierMenuAddonStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.post('/api/menu-addons', data: {
        'menu_id': menuId,
        'addon_id': addonId,
      });

      state = state.copyWith(
        status: CashierMenuAddonStatus.success,
        message: CashierStrings.menuAddonCreated,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierMenuAddonStatus.failure,
        message: _mapError(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierMenuAddonStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
    }
  }

  Future<bool> deleteMenuAddon(int id) async {
    state = state.copyWith(
      status: CashierMenuAddonStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.delete('/api/menu-addons/$id');

      state = state.copyWith(
        status: CashierMenuAddonStatus.success,
        message: CashierStrings.menuAddonDeleted,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierMenuAddonStatus.failure,
        message: _mapError(e),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierMenuAddonStatus.failure,
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
    return CashierStrings.unexpectedError;
  }
}

final cashierMenuAddonProvider =
    NotifierProvider<CashierMenuAddonNotifier, CashierMenuAddonState>(
      CashierMenuAddonNotifier.new,
    );
