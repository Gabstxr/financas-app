import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bill_entity.dart';
import '../repositories/bills_repository.dart';

class GetBills {
  final BillsRepository repository;
  const GetBills(this.repository);
  Future<Either<Failure, List<BillEntity>>> call(String userId) =>
      repository.getBills(userId);
}
