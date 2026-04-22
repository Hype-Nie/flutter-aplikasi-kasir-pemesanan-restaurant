import 'package:equatable/equatable.dart';

abstract class CustomerDashboardEvent extends Equatable {
  const CustomerDashboardEvent();

  @override
  List<Object?> get props => [];
}

class CustomerDashboardStarted extends CustomerDashboardEvent {
  const CustomerDashboardStarted();
}
