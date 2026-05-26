import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bill_entity.dart';
import '../../domain/repositories/bills_repository.dart';
import '../datasources/bills_remote_datasource.dart';
import '../models/bill_model.dart';

class BillsRepositoryImpl implements BillsRepository {
  final BillsRemoteDataSource _dataSource;
  const BillsRepositoryImpl(this._dataSource);

  BillModel _toModel(BillEntity bill) => BillModel(
        id: bill.id,
        userId: bill.userId,
        name: bill.name,
        amount: bill.amount,
        dueDate: bill.dueDate,
        categoryId: bill.categoryId,
        accountId: bill.accountId,
        isPaid: bill.isPaid,
        paidAt: bill.paidAt,
        isRecurring: bill.isRecurring,
        recurringDay: bill.recurringDay,
        notes: bill.notes,
        isActive: bill.isActive,
        createdAt: bill.createdAt,
        updatedAt: bill.updatedAt,
        categoryName: bill.categoryName,
        categoryColor: bill.categoryColor,
        accountName: bill.accountName,
      );

  @override
  Future<Either<Failure, List<BillEntity>>> getBills(String userId) async {
    try {
      return Right(await _dataSource.getBills(userId));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, BillEntity>> addBill(BillEntity bill) async {
    try {
      return Right(await _dataSource.addBill(_toModel(bill)));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, BillEntity>> updateBill(BillEntity bill) async {
    try {
      return Right(await _dataSource.updateBill(_toModel(bill)));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteBill(String userId, String billId) async {
    try {
      await _dataSource.deleteBill(userId, billId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAsPaid(BillEntity bill) async {
    try {
      await _dataSource.markAsPaid(_toModel(bill));
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
