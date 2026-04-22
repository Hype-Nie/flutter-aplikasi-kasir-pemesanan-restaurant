import 'package:equatable/equatable.dart';

enum CustomerChangePasswordStatus { initial, loading, success, failure }

class CustomerChangePasswordState extends Equatable {
  const CustomerChangePasswordState({
    this.status = CustomerChangePasswordStatus.initial,
    this.message = '',
  });

  final CustomerChangePasswordStatus status;
  final String message;

  CustomerChangePasswordState copyWith({
    CustomerChangePasswordStatus? status,
    String? message,
  }) {
    return CustomerChangePasswordState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
