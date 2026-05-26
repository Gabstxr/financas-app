import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bill_entity.dart';
import '../repositories/bills_repository.dart';

class MarkBillPaid {
  final BillsRepository repository;
  const MarkBillPaid(this.repository);
  Future<Either<Failure, void>> call(BillEntity bill) =>
      repository.markAsPaid(bill);
}
