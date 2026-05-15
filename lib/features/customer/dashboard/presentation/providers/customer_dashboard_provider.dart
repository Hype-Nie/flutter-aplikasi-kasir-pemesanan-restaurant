import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/features/customer/domain/entities/category.dart';

enum CustomerDashboardStatus { initial, loading, success, failure }

class CustomerDashboardState extends Equatable {
  final CustomerDashboardStatus status;
  final String message;
  final List<Category> categories;

  const CustomerDashboardState({
    this.status = CustomerDashboardStatus.initial,
    this.message = '',
    this.categories = const [],
  });

  CustomerDashboardState copyWith({
    CustomerDashboardStatus? status,
    String? message,
    List<Category>? categories,
  }) =>
      CustomerDashboardState(
        status: status ?? this.status,
        message: message ?? this.message,
        categories: categories ?? this.categories,
      );

  @override
  List<Object?> get props => [status, message, categories];
}

class CustomerDashboardNotifier extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() => const CustomerDashboardState();

  Future<void> fetchCategories() async {
    state = state.copyWith(status: CustomerDashboardStatus.loading, message: '');

    try {
      final response = await DioClient.instance.get('/api/categories');
      final data = response.data as List<dynamic>;
      final categories = data
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: CustomerDashboardStatus.success,
        categories: categories,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to load categories.';
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) msg = message;
      }
      state = state.copyWith(status: CustomerDashboardStatus.failure, message: msg);
    } catch (_) {
      state = state.copyWith(
        status: CustomerDashboardStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }
}

final customerDashboardProvider =
    NotifierProvider<CustomerDashboardNotifier, CustomerDashboardState>(
        CustomerDashboardNotifier.new);
