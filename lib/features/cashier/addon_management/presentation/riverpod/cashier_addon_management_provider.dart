import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/addon.dart';

enum CashierAddonManagementStatus { initial, loading, success, failure }

class CashierAddonManagementState extends Equatable {
  const CashierAddonManagementState({
    this.status = CashierAddonManagementStatus.initial,
    this.message = '',
    this.addons = const [],
  });

  final CashierAddonManagementStatus status;
  final String message;
  final List<Addon> addons;

  CashierAddonManagementState copyWith({
    CashierAddonManagementStatus? status,
    String? message,
    List<Addon>? addons,
  }) {
    return CashierAddonManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
      addons: addons ?? this.addons,
    );
  }

  @override
  List<Object?> get props => [status, message, addons];
}

class CashierAddonManagementNotifier
    extends Notifier<CashierAddonManagementState> {
  @override
  CashierAddonManagementState build() => const CashierAddonManagementState();

  Future<void> fetchAddons() async {
    state = state.copyWith(
      status: CashierAddonManagementStatus.loading,
      message: '',
    );

    try {
      final response = await DioClient.instance.get('/api/addons');
      final data = response.data as List<dynamic>;
      final addons =
          data.map((e) => Addon.fromJson(e as Map<String, dynamic>)).toList();

      state = state.copyWith(
        status: CashierAddonManagementStatus.success,
        addons: addons,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: _mapError(e, CashierStrings.addonFetchError),
      );
    } catch (_) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  Future<bool> createAddon({
    required String name,
    required int price,
    required String type,
    required bool isAvailable,
  }) async {
    state = state.copyWith(
      status: CashierAddonManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.post('/api/addons', data: {
        'name': name,
        'price': price,
        'type': type,
        'is_available': isAvailable,
      });

      state = state.copyWith(
        status: CashierAddonManagementStatus.success,
        message: CashierStrings.addonCreated,
      );

      await fetchAddons();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
    }
  }

  Future<bool> updateAddon({
    required int id,
    required String name,
    required int price,
    required String type,
    required bool isAvailable,
  }) async {
    state = state.copyWith(
      status: CashierAddonManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.put('/api/addons/$id', data: {
        'name': name,
        'price': price,
        'type': type,
        'is_available': isAvailable,
      });

      state = state.copyWith(
        status: CashierAddonManagementStatus.success,
        message: 'Addon updated successfully',
      );

      await fetchAddons();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
    }
  }

  Future<bool> deleteAddon(int id) async {
    state = state.copyWith(
      status: CashierAddonManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.delete('/api/addons/$id');

      state = state.copyWith(
        status: CashierAddonManagementStatus.success,
        message: CashierStrings.addonDeleted,
      );

      await fetchAddons();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierAddonManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
    }
  }

  String _mapError(DioException e, String fallback) {
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
    return fallback;
  }
}

final cashierAddonManagementProvider =
    NotifierProvider<
      CashierAddonManagementNotifier,
      CashierAddonManagementState
    >(CashierAddonManagementNotifier.new);
