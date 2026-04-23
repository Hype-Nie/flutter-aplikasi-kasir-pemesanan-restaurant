import 'package:equatable/equatable.dart';

abstract class CustomerCartEvent extends Equatable {
  const CustomerCartEvent();

  @override
  List<Object?> get props => [];
}

class CustomerCartStarted extends CustomerCartEvent {
  const CustomerCartStarted();
}

class CustomerCartItemUpdated extends CustomerCartEvent {
  final String id;
  final int quantity;

  const CustomerCartItemUpdated(this.id, this.quantity);

  @override
  List<Object?> get props => [id, quantity];
}

class CustomerCartItemRemoved extends CustomerCartEvent {
  final String id;

  const CustomerCartItemRemoved(this.id);

  @override
  List<Object?> get props => [id];
}
