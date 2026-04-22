import 'package:equatable/equatable.dart';

enum CustomerProfileStatus { initial, loading, success, failure }

class CustomerProfileState extends Equatable {
  const CustomerProfileState({
    this.status = CustomerProfileStatus.initial,
    this.message = '',
  });

  final CustomerProfileStatus status;
  final String message;

  CustomerProfileState copyWith({
    CustomerProfileStatus? status,
    String? message,
  }) {
    return CustomerProfileState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
