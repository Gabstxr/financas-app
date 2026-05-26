import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bill_entity.dart';
import '../repositories/bills_repository.dart';

class UpdateBill {
  final BillsRepository repository;
  const UpdateBill(this.repository);
  Future<Either<Failure, BillEntity>> call(BillEntity bill) =>
      repository.updateBill(bill);
}
