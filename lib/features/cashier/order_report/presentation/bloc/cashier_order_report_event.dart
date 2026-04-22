import 'package:equatable/equatable.dart';

abstract class CashierOrderReportEvent extends Equatable {
  const CashierOrderReportEvent();

  @override
  List<Object?> get props => [];
}

class CashierOrderReportStarted extends CashierOrderReportEvent {
  const CashierOrderReportStarted();
}
