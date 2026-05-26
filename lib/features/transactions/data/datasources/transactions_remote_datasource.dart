import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactionsByMonth(String userId, int year, int month);
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel oldTransaction, TransactionModel newTransaction);
  Future<void> deleteTransaction(TransactionModel transaction);
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final FirebaseFirestore _firestore;

  const TransactionsRemoteDataSourceImpl(this._firestore);

  CollectionReference _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(
    String userId,
    int year,
    int month,
  ) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 0, 23, 59, 59);

      final snapshot = await _collection(userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .where('isDeleted', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc, userId))
          .toList();
    } catch (_) {
      throw const ServerException();
    }
  }

  DocumentReference _accountDoc(String userId, String accountId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('accounts')
      .doc(accountId);

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final batch = _firestore.batch();

      final txRef = _collection(transaction.userId).doc();
      batch.set(txRef, transaction.toFirestore());

      if (!transaction.isTransfer) {
        final delta =
            transaction.isIncome ? transaction.amount : -transaction.amount;
        batch.update(
          _accountDoc(transaction.userId, transaction.accountId),
          {'balance': FieldValue.increment(delta)},
        );
      }

      await batch.commit();
      final doc = await txRef.get();
      return TransactionModel.fromFirestore(doc, transaction.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel oldTransaction,
    TransactionModel newTransaction,
  ) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _collection(newTransaction.userId).doc(newTransaction.id),
        newTransaction.toFirestore(),
      );

      if (!oldTransaction.isTransfer) {
        final reverseDelta =
            oldTransaction.isIncome ? -oldTransaction.amount : oldTransaction.amount;
        batch.update(
          _accountDoc(oldTransaction.userId, oldTransaction.accountId),
          {'balance': FieldValue.increment(reverseDelta)},
        );
      }

      if (!newTransaction.isTransfer) {
        final applyDelta =
            newTransaction.isIncome ? newTransaction.amount : -newTransaction.amount;
        batch.update(
          _accountDoc(newTransaction.userId, newTransaction.accountId),
          {'balance': FieldValue.increment(applyDelta)},
        );
      }

      await batch.commit();
      final doc =
          await _collection(newTransaction.userId).doc(newTransaction.id).get();
      return TransactionModel.fromFirestore(doc, newTransaction.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteTransaction(TransactionModel transaction) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _collection(transaction.userId).doc(transaction.id),
        {'isDeleted': true, 'updatedAt': FieldValue.serverTimestamp()},
      );

      if (!transaction.isTransfer) {
        final reverseDelta =
            transaction.isIncome ? -transaction.amount : transaction.amount;
        batch.update(
          _accountDoc(transaction.userId, transaction.accountId),
          {'balance': FieldValue.increment(reverseDelta)},
        );
      }

      await batch.commit();
    } catch (_) {
      throw const ServerException();
    }
  }
}
