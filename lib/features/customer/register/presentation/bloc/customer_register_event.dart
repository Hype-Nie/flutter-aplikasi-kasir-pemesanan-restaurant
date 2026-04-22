import 'package:equatable/equatable.dart';

abstract class CustomerRegisterEvent extends Equatable {
  const CustomerRegisterEvent();

  @override
  List<Object?> get props => [];
}

class CustomerRegisterStarted extends CustomerRegisterEvent {
  const CustomerRegisterStarted();
}
