import 'package:equatable/equatable.dart';

abstract class CashierCategoryManagementEvent extends Equatable {
  const CashierCategoryManagementEvent();

  @override
  List<Object?> get props => [];
}

class CashierCategoryManagementStarted extends CashierCategoryManagementEvent {
  const CashierCategoryManagementStarted();
}
