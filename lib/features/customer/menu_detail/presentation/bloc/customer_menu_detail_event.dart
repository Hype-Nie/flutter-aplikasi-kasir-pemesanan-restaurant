import 'package:equatable/equatable.dart';

abstract class CustomerMenuDetailEvent extends Equatable {
  const CustomerMenuDetailEvent();

  @override
  List<Object?> get props => [];
}

class CustomerMenuDetailStarted extends CustomerMenuDetailEvent {
  const CustomerMenuDetailStarted();
}
