import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';
import '../repositories/accounts_repository.dart';

class GetAccounts {
  final AccountsRepository repository;
  const GetAccounts(this.repository);

  Future<Either<Failure, List<AccountEntity>>> call(String userId) {
    return repository.getAccounts(userId);
  }
}
