import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/category.dart';

enum CashierCategoryManagementStatus { initial, loading, success, failure }

class CashierCategoryManagementState extends Equatable {
  const CashierCategoryManagementState({
    this.status = CashierCategoryManagementStatus.initial,
    this.message = '',
    this.categories = const [],
  });

  final CashierCategoryManagementStatus status;
  final String message;
  final List<Category> categories;

  CashierCategoryManagementState copyWith({
    CashierCategoryManagementStatus? status,
    String? message,
    List<Category>? categories,
  }) {
    return CashierCategoryManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [status, message, categories];
}

class CashierCategoryManagementNotifier
    extends Notifier<CashierCategoryManagementState> {
  @override
  CashierCategoryManagementState build() =>
      const CashierCategoryManagementState();

  Future<void> fetchCategories() async {
    state = state.copyWith(
      status: CashierCategoryManagementStatus.loading,
      message: '',
    );

    try {
      final response = await DioClient.instance.get('/api/categories');
      final data = response.data as List<dynamic>;
      final categories =
          data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();

      state = state.copyWith(
        status: CashierCategoryManagementStatus.success,
        categories: categories,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: _mapError(e, CashierStrings.categoryFetchError),
      );
    } catch (_) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  Future<bool> createCategory(String name, String description) async {
    state = state.copyWith(
      status: CashierCategoryManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.post('/api/categories', data: {
        'name': name,
        'description': description,
      });

      state = state.copyWith(
        status: CashierCategoryManagementStatus.success,
        message: CashierStrings.categoryCreated,
      );

      await fetchCategories();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
    }
  }

  Future<bool> updateCategory(int id, {String? name, String? description}) async {
    state = state.copyWith(
      status: CashierCategoryManagementStatus.loading,
      message: '',
    );

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      await DioClient.instance.put('/api/categories/$id', data: data);

      state = state.copyWith(
        status: CashierCategoryManagementStatus.success,
        message: CashierStrings.categoryUpdated,
      );

      await fetchCategories();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    state = state.copyWith(
      status: CashierCategoryManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.delete('/api/categories/$id');

      state = state.copyWith(
        status: CashierCategoryManagementStatus.success,
        message: CashierStrings.categoryDeleted,
      );

      await fetchCategories();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        status: CashierCategoryManagementStatus.failure,
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

final cashierCategoryManagementProvider =
    NotifierProvider<
      CashierCategoryManagementNotifier,
      CashierCategoryManagementState
    >(CashierCategoryManagementNotifier.new);
