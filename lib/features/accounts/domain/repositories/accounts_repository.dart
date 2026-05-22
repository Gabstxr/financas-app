import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/account_entity.dart';

abstract class AccountsRepository {
  Future<Either<Failure, List<AccountEntity>>> getAccounts(String userId);
  Future<Either<Failure, AccountEntity>> addAccount(AccountEntity account);
  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account);
  Future<Either<Failure, void>> deleteAccount(String userId, String accountId);
  Future<Either<Failure, void>> updateBalance(String userId, String accountId, int newBalance);
}
