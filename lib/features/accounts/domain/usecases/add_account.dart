import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/accounts_repository.dart';

class AddAccount {
  final AccountsRepository repository;
  const AddAccount(this.repository);

  Future<Either<Failure, AccountEntity>> call(AccountEntity account) {
    return repository.addAccount(account);
  }
}
