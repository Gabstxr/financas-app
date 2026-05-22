import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionsByMonth {
  final TransactionsRepository repository;
  const GetTransactionsByMonth(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call(
    String userId,
    int year,
    int month,
  ) {
    return repository.getTransactionsByMonth(userId, year, month);
  }
}
