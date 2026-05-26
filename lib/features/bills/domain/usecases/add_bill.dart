import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bill_entity.dart';
import '../repositories/bills_repository.dart';

class AddBill {
  final BillsRepository repository;
  const AddBill(this.repository);
  Future<Either<Failure, BillEntity>> call(BillEntity bill) =>
      repository.addBill(bill);
}
