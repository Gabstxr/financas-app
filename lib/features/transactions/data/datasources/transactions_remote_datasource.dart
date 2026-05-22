import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactionsByMonth(String userId, int year, int month);
  Future<TransactionModel> addTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
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

  @override
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _collection(transaction.userId).add(transaction.toFirestore());
      final doc = await docRef.get();
      return TransactionModel.fromFirestore(doc, transaction.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      await _collection(transaction.userId)
          .doc(transaction.id)
          .update(transaction.toFirestore());
      final doc = await _collection(transaction.userId).doc(transaction.id).get();
      return TransactionModel.fromFirestore(doc, transaction.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _collection(userId).doc(transactionId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw const ServerException();
    }
  }
}
