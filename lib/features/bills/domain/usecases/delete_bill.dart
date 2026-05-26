import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/bills_repository.dart';

class DeleteBill {
  final BillsRepository repository;
  const DeleteBill(this.repository);
  Future<Either<Failure, void>> call(String userId, String billId) =>
      repository.deleteBill(userId, billId);
}
