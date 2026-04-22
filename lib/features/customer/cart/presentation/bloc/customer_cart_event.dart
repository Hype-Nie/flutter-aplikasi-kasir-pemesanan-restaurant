import 'package:equatable/equatable.dart';

abstract class CustomerCartEvent extends Equatable {
  const CustomerCartEvent();

  @override
  List<Object?> get props => [];
}

class CustomerCartStarted extends CustomerCartEvent {
  const CustomerCartStarted();
}
