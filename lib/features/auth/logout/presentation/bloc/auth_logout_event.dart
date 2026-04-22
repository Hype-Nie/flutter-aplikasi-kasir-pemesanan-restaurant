import 'package:equatable/equatable.dart';

abstract class AuthLogoutEvent extends Equatable {
  const AuthLogoutEvent();

  @override
  List<Object?> get props => [];
}

class AuthLogoutStarted extends AuthLogoutEvent {
  const AuthLogoutStarted();
}
