import 'package:equatable/equatable.dart';

abstract class CustomerOrderHistoryEvent extends Equatable {
  const CustomerOrderHistoryEvent();

  @override
  List<Object?> get props => [];
}

class CustomerOrderHistoryStarted extends CustomerOrderHistoryEvent {
  const CustomerOrderHistoryStarted();
}
