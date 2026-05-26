import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../models/bill_model.dart';

abstract class BillsRemoteDataSource {
  Future<List<BillModel>> getBills(String userId);
  Future<BillModel> addBill(BillModel bill);
  Future<BillModel> updateBill(BillModel bill);
  Future<void> deleteBill(String userId, String billId);
  Future<void> markAsPaid(BillModel bill);
}

class BillsRemoteDataSourceImpl implements BillsRemoteDataSource {
  final FirebaseFirestore _firestore;

  const BillsRemoteDataSourceImpl(this._firestore);

  CollectionReference _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('bills');

  @override
  Future<List<BillModel>> getBills(String userId) async {
    try {
      final snapshot = await _collection(userId)
          .where('isActive', isEqualTo: true)
          .orderBy('dueDate')
          .get();
      return snapshot.docs
          .map((doc) => BillModel.fromFirestore(doc, userId))
          .toList();
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<BillModel> addBill(BillModel bill) async {
    try {
      final docRef = await _collection(bill.userId).add(bill.toFirestore());
      final doc = await docRef.get();
      return BillModel.fromFirestore(doc, bill.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<BillModel> updateBill(BillModel bill) async {
    try {
      await _collection(bill.userId).doc(bill.id).update(bill.toFirestore());
      final doc = await _collection(bill.userId).doc(bill.id).get();
      return BillModel.fromFirestore(doc, bill.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteBill(String userId, String billId) async {
    try {
      await _collection(userId).doc(billId).update({'isActive': false});
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> markAsPaid(BillModel bill) async {
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      // Marca a conta como paga
      batch.update(_collection(bill.userId).doc(bill.id), {
        'isPaid': true,
        'paidAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Cria transação de despesa
      final txRef = _firestore
          .collection('users')
          .doc(bill.userId)
          .collection('transactions')
          .doc();

      final tx = TransactionModel(
        id: txRef.id,
        userId: bill.userId,
        type: FullTransactionType.expense,
        amount: bill.amount,
        description: bill.name,
        categoryId: bill.categoryId,
        accountId: bill.accountId,
        date: now,
        createdAt: now,
        updatedAt: now,
        categoryName: bill.categoryName,
        categoryColor: bill.categoryColor,
        accountName: bill.accountName,
      );
      batch.set(txRef, tx.toFirestore());

      // Atualiza saldo da conta
      if (bill.amount > 0) {
        final accountRef = _firestore
            .collection('users')
            .doc(bill.userId)
            .collection('accounts')
            .doc(bill.accountId);
        batch.update(accountRef, {'balance': FieldValue.increment(-bill.amount)});
      }

      await batch.commit();

      // Se recorrente, cria próxima instância
      if (bill.isRecurring) {
        final nextDue = _nextDueDate(bill.dueDate, bill.recurringDay);
        final nextBill = BillModel(
          id: '',
          userId: bill.userId,
          name: bill.name,
          amount: bill.amount,
          dueDate: nextDue,
          categoryId: bill.categoryId,
          accountId: bill.accountId,
          isRecurring: true,
          recurringDay: bill.recurringDay,
          notes: bill.notes,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          categoryName: bill.categoryName,
          categoryColor: bill.categoryColor,
          accountName: bill.accountName,
        );
        await addBill(nextBill);
      }
    } catch (_) {
      throw const ServerException();
    }
  }

  DateTime _nextDueDate(DateTime current, int? recurringDay) {
    final day = recurringDay ?? current.day;
    var next = DateTime(current.year, current.month + 1, 1);
    final lastDay = DateTime(next.year, next.month + 1, 0).day;
    return DateTime(next.year, next.month, day.clamp(1, lastDay));
  }
}
