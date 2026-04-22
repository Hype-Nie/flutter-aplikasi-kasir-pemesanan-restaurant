import 'package:equatable/equatable.dart';

enum CustomerRegisterStatus { initial, loading, success, failure }

class CustomerRegisterState extends Equatable {
  const CustomerRegisterState({
    this.status = CustomerRegisterStatus.initial,
    this.message = '',
  });

  final CustomerRegisterStatus status;
  final String message;

  CustomerRegisterState copyWith({
    CustomerRegisterStatus? status,
    String? message,
  }) {
    return CustomerRegisterState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
