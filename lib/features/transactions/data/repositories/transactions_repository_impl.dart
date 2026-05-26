import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource _dataSource;
  const TransactionsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByMonth(
    String userId,
    int year,
    int month,
  ) async {
    try {
      final transactions = await _dataSource.getTransactionsByMonth(userId, year, month);
      return Right(transactions);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = _toModel(transaction);
      final result = await _dataSource.addTransaction(model);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity oldTransaction,
    TransactionEntity newTransaction,
  ) async {
    try {
      final result = await _dataSource.updateTransaction(
        _toModel(oldTransaction),
        _toModel(newTransaction),
      );
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(TransactionEntity transaction) async {
    try {
      await _dataSource.deleteTransaction(_toModel(transaction));
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  TransactionModel _toModel(TransactionEntity t) => TransactionModel(
        id: t.id,
        userId: t.userId,
        type: t.type,
        amount: t.amount,
        description: t.description,
        categoryId: t.categoryId,
        accountId: t.accountId,
        toAccountId: t.toAccountId,
        date: t.date,
        isRecurring: t.isRecurring,
        recurrenceId: t.recurrenceId,
        notes: t.notes,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
        isDeleted: t.isDeleted,
        categoryName: t.categoryName,
        categoryIcon: t.categoryIcon,
        categoryColor: t.categoryColor,
        accountName: t.accountName,
      );
}
