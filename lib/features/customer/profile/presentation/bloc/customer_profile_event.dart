import 'package:equatable/equatable.dart';

abstract class CustomerProfileEvent extends Equatable {
  const CustomerProfileEvent();

  @override
  List<Object?> get props => [];
}

class CustomerProfileStarted extends CustomerProfileEvent {
  const CustomerProfileStarted();
}
