import 'package:equatable/equatable.dart';

abstract class CashierMenuManagementEvent extends Equatable {
  const CashierMenuManagementEvent();

  @override
  List<Object?> get props => [];
}

class CashierMenuManagementStarted extends CashierMenuManagementEvent {
  const CashierMenuManagementStarted();
}
