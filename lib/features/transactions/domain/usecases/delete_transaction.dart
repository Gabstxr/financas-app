import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transactions_repository.dart';

class DeleteTransaction {
  final TransactionsRepository repository;
  const DeleteTransaction(this.repository);

  Future<Either<Failure, void>> call(TransactionEntity transaction) {
    return repository.deleteTransaction(transaction);
  }
}
