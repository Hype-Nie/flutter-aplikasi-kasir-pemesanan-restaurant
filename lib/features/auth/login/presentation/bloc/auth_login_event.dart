import 'package:equatable/equatable.dart';

abstract class AuthLoginEvent extends Equatable {
  const AuthLoginEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginStarted extends AuthLoginEvent {
  const AuthLoginStarted();
}
