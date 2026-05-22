import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/accounts_repository.dart';

class DeleteAccount {
  final AccountsRepository repository;
  const DeleteAccount(this.repository);

  Future<Either<Failure, void>> call(String userId, String accountId) {
    return repository.deleteAccount(userId, accountId);
  }
}
