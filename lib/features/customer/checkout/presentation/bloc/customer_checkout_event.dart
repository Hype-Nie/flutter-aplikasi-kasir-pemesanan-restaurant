import 'package:equatable/equatable.dart';

abstract class CustomerCheckoutEvent extends Equatable {
  const CustomerCheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CustomerCheckoutStarted extends CustomerCheckoutEvent {
  const CustomerCheckoutStarted();
}
