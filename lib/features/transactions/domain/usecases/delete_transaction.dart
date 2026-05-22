import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/transactions_repository.dart';

class DeleteTransaction {
  final TransactionsRepository repository;
  const DeleteTransaction(this.repository);

  Future<Either<Failure, void>> call(String userId, String transactionId) {
    return repository.deleteTransaction(userId, transactionId);
  }
}
