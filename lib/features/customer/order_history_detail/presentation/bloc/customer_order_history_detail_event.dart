import 'package:equatable/equatable.dart';

abstract class CustomerOrderHistoryDetailEvent extends Equatable {
  const CustomerOrderHistoryDetailEvent();

  @override
  List<Object?> get props => [];
}

class CustomerOrderHistoryDetailStarted extends CustomerOrderHistoryDetailEvent {
  const CustomerOrderHistoryDetailStarted();
}
