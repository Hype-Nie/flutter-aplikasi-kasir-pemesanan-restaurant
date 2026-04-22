import 'package:equatable/equatable.dart';

enum CustomerMenuDetailStatus { initial, loading, success, failure }

class CustomerMenuDetailState extends Equatable {
  const CustomerMenuDetailState({
    this.status = CustomerMenuDetailStatus.initial,
    this.message = '',
  });

  final CustomerMenuDetailStatus status;
  final String message;

  CustomerMenuDetailState copyWith({
    CustomerMenuDetailStatus? status,
    String? message,
  }) {
    return CustomerMenuDetailState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
