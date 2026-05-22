import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/accounts_repository.dart';

class UpdateAccount {
  final AccountsRepository repository;
  const UpdateAccount(this.repository);

  Future<Either<Failure, AccountEntity>> call(AccountEntity account) {
    return repository.updateAccount(account);
  }
}
