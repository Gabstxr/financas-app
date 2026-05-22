import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_datasource.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource _dataSource;

  const AccountsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts(String userId) async {
    try {
      final accounts = await _dataSource.getAccounts(userId);
      return Right(accounts);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> addAccount(AccountEntity account) async {
    try {
      final model = AccountModel(
        id: account.id,
        userId: account.userId,
        name: account.name,
        type: account.type,
        balance: account.balance,
        initialBalance: account.initialBalance,
        color: account.color,
        icon: account.icon,
        isActive: account.isActive,
        createdAt: account.createdAt,
      );
      final result = await _dataSource.addAccount(model);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account) async {
    try {
      final model = AccountModel(
        id: account.id,
        userId: account.userId,
        name: account.name,
        type: account.type,
        balance: account.balance,
        initialBalance: account.initialBalance,
        color: account.color,
        icon: account.icon,
        isActive: account.isActive,
        createdAt: account.createdAt,
      );
      final result = await _dataSource.updateAccount(model);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId, String accountId) async {
    try {
      await _dataSource.deleteAccount(userId, accountId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateBalance(
      String userId, String accountId, int newBalance) async {
    try {
      await _dataSource.updateBalance(userId, accountId, newBalance);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
