import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:restaurant/config/strings/cashier_strings.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/shared/models/category.dart';
import 'package:restaurant/shared/models/menu.dart';

enum CashierMenuManagementStatus { initial, loading, success, failure }

class CashierMenuManagementState extends Equatable {
  const CashierMenuManagementState({
    this.status = CashierMenuManagementStatus.initial,
    this.message = '',
    this.menus = const [],
    this.categories = const [],
  });

  final CashierMenuManagementStatus status;
  final String message;
  final List<Menu> menus;
  final List<Category> categories;

  CashierMenuManagementState copyWith({
    CashierMenuManagementStatus? status,
    String? message,
    List<Menu>? menus,
    List<Category>? categories,
  }) {
    return CashierMenuManagementState(
      status: status ?? this.status,
      message: message ?? this.message,
      menus: menus ?? this.menus,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [status, message, menus, categories];
}

class CashierMenuManagementNotifier
    extends Notifier<CashierMenuManagementState> {
  @override
  CashierMenuManagementState build() => const CashierMenuManagementState();

  Future<void> fetchMenus() async {
    state = state.copyWith(
      status: CashierMenuManagementStatus.loading,
      message: '',
    );

    try {
      final responses = await Future.wait([
        DioClient.instance.get('/api/menus'),
        DioClient.instance.get('/api/categories'),
      ]);

      final menusData = responses[0].data as List<dynamic>;
      final categoriesData = responses[1].data as List<dynamic>;

      final menus = menusData
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList();
      final categories = categoriesData
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: CashierMenuManagementStatus.success,
        menus: menus,
        categories: categories,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: _mapError(e, CashierStrings.menuFetchError),
      );
    } catch (e, stackTrace) {
      debugPrint('[MenuManagement] fetchMenus unexpected error: $e');
      debugPrint('[MenuManagement] stackTrace: $stackTrace');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: CashierStrings.unexpectedError,
      );
    }
  }

  Future<bool> createMenu({
    required int categoryId,
    required String name,
    required int price,
    required bool isAvailable,
    String? description,
    XFile? imageFile,
  }) async {
    state = state.copyWith(
      status: CashierMenuManagementStatus.loading,
      message: '',
    );

    try {
      final body = <String, dynamic>{
        'category_id': categoryId,
        'name': name,
        'price': price,
        'is_available': isAvailable ? 1 : 0,
      };
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (imageFile != null) {
        final mime = _mimeFromPath(imageFile.path);
        body['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
          contentType: mime,
        );
        debugPrint('[MenuManagement] createMenu with image: ${imageFile.name} (${mime.mimeType})');
        await DioClient.instance.post(
          '/api/menus',
          data: FormData.fromMap(body),
        );
      } else {
        debugPrint('[MenuManagement] createMenu without image');
        await DioClient.instance.post('/api/menus', data: body);
      }

      state = state.copyWith(
        status: CashierMenuManagementStatus.success,
        message: CashierStrings.menuCreated,
      );

      await fetchMenus();
      return true;
    } on DioException catch (e) {
      debugPrint('[MenuManagement] createMenu DioException: ${e.response?.statusCode} ${e.response?.data}');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('[MenuManagement] createMenu unexpected error: $e');
      debugPrint('[MenuManagement] stackTrace: $stackTrace');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: 'Error: $e',
      );
      return false;
    }
  }

  Future<bool> updateMenu(
    int id, {
    int? price,
    String? description,
    XFile? imageFile,
    String? name,
    int? categoryId,
    bool? isAvailable,
  }) async {
    state = state.copyWith(
      status: CashierMenuManagementStatus.loading,
      message: '',
    );

    try {
      final data = <String, dynamic>{};
      if (price != null) data['price'] = price;
      if (description != null) data['description'] = description;
      if (name != null) data['name'] = name;
      if (categoryId != null) data['category_id'] = categoryId;
      if (isAvailable != null) data['is_available'] = isAvailable ? 1 : 0;

      if (imageFile != null) {
        final mime = _mimeFromPath(imageFile.path);
        data['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
          contentType: mime,
        );
        // Laravel doesn't support PUT with multipart, use POST + _method
        data['_method'] = 'PUT';
        debugPrint('[MenuManagement] updateMenu $id with image: ${imageFile.name}');
        await DioClient.instance.post(
          '/api/menus/$id',
          data: FormData.fromMap(data),
        );
      } else {
        debugPrint('[MenuManagement] updateMenu $id without image, data: $data');
        await DioClient.instance.put('/api/menus/$id', data: data);
      }

      state = state.copyWith(
        status: CashierMenuManagementStatus.success,
        message: CashierStrings.menuUpdated,
      );

      await fetchMenus();
      return true;
    } on DioException catch (e) {
      debugPrint('[MenuManagement] updateMenu DioException: ${e.response?.statusCode} ${e.response?.data}');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('[MenuManagement] updateMenu unexpected error: $e');
      debugPrint('[MenuManagement] stackTrace: $stackTrace');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: 'Error: $e',
      );
      return false;
    }
  }

  Future<bool> deleteMenu(int id) async {
    state = state.copyWith(
      status: CashierMenuManagementStatus.loading,
      message: '',
    );

    try {
      await DioClient.instance.delete('/api/menus/$id');

      state = state.copyWith(
        status: CashierMenuManagementStatus.success,
        message: CashierStrings.menuDeleted,
      );

      await fetchMenus();
      return true;
    } on DioException catch (e) {
      debugPrint('[MenuManagement] deleteMenu DioException: ${e.response?.statusCode} ${e.response?.data}');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: _mapError(e, CashierStrings.unexpectedError),
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('[MenuManagement] deleteMenu unexpected error: $e');
      debugPrint('[MenuManagement] stackTrace: $stackTrace');
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: 'Error: $e',
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

  MediaType _mimeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}

final cashierMenuManagementProvider =
    NotifierProvider<CashierMenuManagementNotifier, CashierMenuManagementState>(
      CashierMenuManagementNotifier.new,
    );
