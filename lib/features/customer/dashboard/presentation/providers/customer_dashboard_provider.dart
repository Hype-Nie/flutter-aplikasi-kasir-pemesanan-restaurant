import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/features/customer/domain/entities/category.dart';
import 'package:restaurant/features/customer/domain/entities/menu.dart';

enum CustomerDashboardStatus { initial, loading, success, failure }

class CustomerDashboardState extends Equatable {
  final CustomerDashboardStatus status;
  final String message;
  final List<Category> categories;
  final List<Menu> menus;

  const CustomerDashboardState({
    this.status = CustomerDashboardStatus.initial,
    this.message = '',
    this.categories = const [],
    this.menus = const [],
  });

  CustomerDashboardState copyWith({
    CustomerDashboardStatus? status,
    String? message,
    List<Category>? categories,
    List<Menu>? menus,
  }) => CustomerDashboardState(
    status: status ?? this.status,
    message: message ?? this.message,
    categories: categories ?? this.categories,
    menus: menus ?? this.menus,
  );

  @override
  List<Object?> get props => [status, message, categories, menus];
}

class CustomerDashboardNotifier extends Notifier<CustomerDashboardState> {
  @override
  CustomerDashboardState build() => const CustomerDashboardState();

  Future<void> fetchDashboardData() async {
    state = state.copyWith(
      status: CustomerDashboardStatus.loading,
      message: '',
    );

    try {
      final results = await Future.wait([
        DioClient.instance.get('/api/categories'),
        DioClient.instance.get('/api/menus'),
      ]);

      final categories = (results[0].data as List<dynamic>)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      final menus = (results[1].data as List<dynamic>)
          .map((json) => Menu.fromJson(json as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: CustomerDashboardStatus.success,
        categories: categories,
        menus: menus,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to load data.';
      
      if (e.type == DioExceptionType.connectionError && 
          e.error.toString().contains('No internet connection')) {
        msg = 'No internet connection';
      } else if (data is Map) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) msg = message;
      }
      
      state = state.copyWith(
        status: CustomerDashboardStatus.failure,
        message: msg,
      );
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
      CustomerDashboardNotifier.new,
    );
