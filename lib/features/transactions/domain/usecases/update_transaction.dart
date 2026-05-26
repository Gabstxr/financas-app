import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transactions_repository.dart';

class UpdateTransaction {
  final TransactionsRepository repository;
  const UpdateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity oldTransaction,
    TransactionEntity newTransaction,
  ) {
    return repository.updateTransaction(oldTransaction, newTransaction);
  }
}
