import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro no servidor. Tente novamente.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'E-mail ou senha incorretos.']);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure([super.message = 'Este e-mail já está em uso.']);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([super.message = 'A senha deve ter no mínimo 6 caracteres.']);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([super.message = 'Usuário não encontrado.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro ao acessar dados locais.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Sem permissão para esta ação.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Registro não encontrado.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocorreu um erro inesperado.']);
}
