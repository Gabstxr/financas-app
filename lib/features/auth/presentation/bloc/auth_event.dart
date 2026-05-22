part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class AuthSignOutRequested extends AuthEvent {}

class _AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
