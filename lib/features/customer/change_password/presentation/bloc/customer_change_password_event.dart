import 'package:equatable/equatable.dart';

abstract class CustomerChangePasswordEvent extends Equatable {
  const CustomerChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class CustomerChangePasswordStarted extends CustomerChangePasswordEvent {
  const CustomerChangePasswordStarted();
}
