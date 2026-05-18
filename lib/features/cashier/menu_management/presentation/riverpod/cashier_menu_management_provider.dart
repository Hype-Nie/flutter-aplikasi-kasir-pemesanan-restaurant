import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

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
  static const int _maxImageBytes = 2 * 1024 * 1024; // 2MB

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
        body['image'] = await _buildMenuImagePart(imageFile);
      }
      debugPrint('[MenuManagement] createMenu multipart keys: ${body.keys.join(",")}');
      await DioClient.instance.post('/api/menus', data: FormData.fromMap(body));

      state = state.copyWith(
        status: CashierMenuManagementStatus.success,
        message: CashierStrings.menuCreated,
      );

      await fetchMenus();
      return true;
    } on _MenuImageUploadException catch (e) {
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: e.message,
      );
      return false;
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
        data['image'] = await _buildMenuImagePart(imageFile);
        // Laravel doesn't support PUT with multipart, use POST + _method
        data['_method'] = 'PUT';
        debugPrint('[MenuManagement] updateMenu $id multipart keys: ${data.keys.join(",")}');
        await DioClient.instance.post(
          '/api/menus/$id',
          data: FormData.fromMap(data),
          options: Options(
            headers: const {'X-HTTP-Method-Override': 'PUT'},
          ),
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
    } on _MenuImageUploadException catch (e) {
      state = state.copyWith(
        status: CashierMenuManagementStatus.failure,
        message: e.message,
      );
      return false;
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

  Future<MultipartFile> _buildMenuImagePart(XFile imageFile) async {
    final originalBytes = await imageFile.readAsBytes();
    final ext = _fileExtension(imageFile.name);
    Uint8List uploadBytes = Uint8List.fromList(originalBytes);
    MediaType contentType = _mimeFromExt(ext);
    var filename = imageFile.name;

    final unsupportedExt = ext != 'jpg' &&
        ext != 'jpeg' &&
        ext != 'png' &&
        ext != 'gif' &&
        ext != 'webp' &&
        ext != 'bmp';
    final tooLarge = uploadBytes.length > _maxImageBytes;

    if (unsupportedExt || tooLarge) {
      uploadBytes = await _compressToJpeg(uploadBytes);
      contentType = MediaType('image', 'jpeg');
      filename = '${_fileNameWithoutExtension(imageFile.name)}.jpg';
    }

    if (uploadBytes.length > _maxImageBytes) {
      throw const _MenuImageUploadException('Image maksimal 2MB.');
    }

    return MultipartFile.fromBytes(
      uploadBytes,
      filename: filename,
      contentType: contentType,
    );
  }

  Future<Uint8List> _compressToJpeg(Uint8List input) async {
    final compressed = await FlutterImageCompress.compressWithList(
      input,
      minWidth: 1280,
      minHeight: 1280,
      quality: 75,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (compressed.isEmpty) {
      throw const _MenuImageUploadException('Gagal memproses gambar.');
    }
    return compressed;
  }

  String _fileExtension(String filename) {
    final idx = filename.lastIndexOf('.');
    if (idx == -1 || idx == filename.length - 1) return '';
    return filename.substring(idx + 1).toLowerCase();
  }

  String _fileNameWithoutExtension(String filename) {
    final idx = filename.lastIndexOf('.');
    if (idx <= 0) return filename;
    return filename.substring(0, idx);
  }

  MediaType _mimeFromExt(String ext) {
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
      case 'bmp':
        return MediaType('image', 'bmp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}

class _MenuImageUploadException implements Exception {
  const _MenuImageUploadException(this.message);

  final String message;
}

final cashierMenuManagementProvider =
    NotifierProvider<CashierMenuManagementNotifier, CashierMenuManagementState>(
      CashierMenuManagementNotifier.new,
    );
