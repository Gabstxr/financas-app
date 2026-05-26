import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/accounts_repository.dart';

class RecalculateBalances {
  final AccountsRepository repository;
  const RecalculateBalances(this.repository);

  Future<Either<Failure, void>> call(String userId) {
    return repository.recalculateBalances(userId);
  }
}
