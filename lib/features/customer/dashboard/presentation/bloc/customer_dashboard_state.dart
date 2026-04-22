import 'package:equatable/equatable.dart';

enum CustomerDashboardStatus { initial, loading, success, failure }

class CustomerDashboardState extends Equatable {
  const CustomerDashboardState({
    this.status = CustomerDashboardStatus.initial,
    this.message = '',
  });

  final CustomerDashboardStatus status;
  final String message;

  CustomerDashboardState copyWith({
    CustomerDashboardStatus? status,
    String? message,
  }) {
    return CustomerDashboardState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
