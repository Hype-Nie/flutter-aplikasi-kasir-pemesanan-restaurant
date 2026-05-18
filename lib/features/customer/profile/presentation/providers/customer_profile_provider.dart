import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restaurant/core/network/dio_client.dart';
import 'package:restaurant/core/utils/token_storage.dart';
import 'package:restaurant/features/auth/domain/entities/user.dart';

enum CustomerProfileStatus { initial, loading, success, failure }

class CustomerProfileState extends Equatable {
  final CustomerProfileStatus status;
  final String message;
  final User? user;

  const CustomerProfileState({
    this.status = CustomerProfileStatus.initial,
    this.message = '',
    this.user,
  });

  CustomerProfileState copyWith({
    CustomerProfileStatus? status,
    String? message,
    User? user,
  }) => CustomerProfileState(
    status: status ?? this.status,
    message: message ?? this.message,
    user: user ?? this.user,
  );

  @override
  List<Object?> get props => [status, message, user];
}

class CustomerProfileNotifier extends Notifier<CustomerProfileState> {
  @override
  CustomerProfileState build() => const CustomerProfileState();

  Future<void> fetchUser() async {
    state = state.copyWith(status: CustomerProfileStatus.loading, message: '');

    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        state = state.copyWith(
          status: CustomerProfileStatus.failure,
          message: 'User not found.',
        );
        return;
      }

      final response = await DioClient.instance.get('/api/users/$userId');
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);

      state = state.copyWith(status: CustomerProfileStatus.success, user: user);
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to load profile.';
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) msg = message;
      }
      state = state.copyWith(
        status: CustomerProfileStatus.failure,
        message: msg,
      );
    } catch (_) {
      state = state.copyWith(
        status: CustomerProfileStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }

  Future<void> updateUser({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatarPath,
  }) async {
    state = state.copyWith(status: CustomerProfileStatus.loading, message: '');

    try {
      final userId = await TokenStorage.getUserId();
      if (userId == null) {
        state = state.copyWith(
          status: CustomerProfileStatus.failure,
          message: 'User not found.',
        );
        return;
      }

      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      Response response;
      if (avatarPath != null) {
        final formData = FormData();
        formData.fields.add(MapEntry('_method', 'PUT'));
        formData.files.add(
          MapEntry(
            'avatar',
            await MultipartFile.fromFile(avatarPath, filename: 'avatar.jpg'),
          ),
        );
        response = await DioClient.instance.put(
          '/api/users/$userId',
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        response = await DioClient.instance.put(
          '/api/users/$userId',
          data: data,
        );
      }

      final responseData = response.data as Map<String, dynamic>;
      final updatedUser = User.fromJson(responseData);
      state = state.copyWith(
        status: CustomerProfileStatus.success,
        user: updatedUser,
        message: 'Profile updated.',
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'Failed to update profile.';
      if (data is Map) {
        if (data.containsKey('errors') && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          msg = (errors.values.first as List).first.toString();
        } else if (data.containsKey('message')) {
          msg = data['message'].toString();
        }
      }
      state = state.copyWith(
        status: CustomerProfileStatus.failure,
        message: msg,
      );
    } catch (_) {
      state = state.copyWith(
        status: CustomerProfileStatus.failure,
        message: 'Something went wrong.',
      );
    }
  }
}

final customerProfileProvider =
    NotifierProvider<CustomerProfileNotifier, CustomerProfileState>(
      CustomerProfileNotifier.new,
    );
