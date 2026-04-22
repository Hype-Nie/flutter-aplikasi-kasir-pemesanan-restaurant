import 'package:equatable/equatable.dart';

abstract class CashierDashboardEvent extends Equatable {
  const CashierDashboardEvent();

  @override
  List<Object?> get props => [];
}

class CashierDashboardStarted extends CashierDashboardEvent {
  const CashierDashboardStarted();
}
