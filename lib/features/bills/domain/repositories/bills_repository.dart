import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bill_entity.dart';

abstract class BillsRepository {
  Future<Either<Failure, List<BillEntity>>> getBills(String userId);
  Future<Either<Failure, BillEntity>> addBill(BillEntity bill);
  Future<Either<Failure, BillEntity>> updateBill(BillEntity bill);
  Future<Either<Failure, void>> deleteBill(String userId, String billId);
  Future<Either<Failure, void>> markAsPaid(BillEntity bill);
}
