import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByMonth(
    String userId,
    int year,
    int month,
  );
  Future<Either<Failure, TransactionEntity>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, TransactionEntity>> updateTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> deleteTransaction(String userId, String transactionId);
}
