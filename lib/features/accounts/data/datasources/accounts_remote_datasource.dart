import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/account_model.dart';

abstract class AccountsRemoteDataSource {
  Future<List<AccountModel>> getAccounts(String userId);
  Future<AccountModel> addAccount(AccountModel account);
  Future<AccountModel> updateAccount(AccountModel account);
  Future<void> deleteAccount(String userId, String accountId);
  Future<void> updateBalance(String userId, String accountId, int newBalance);
  Future<void> recalculateBalances(String userId);
}

class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  final FirebaseFirestore _firestore;

  const AccountsRemoteDataSourceImpl(this._firestore);

  CollectionReference _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('accounts');

  @override
  Future<List<AccountModel>> getAccounts(String userId) async {
    try {
      final snapshot = await _collection(userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt')
          .get();
      return snapshot.docs
          .map((doc) => AccountModel.fromFirestore(doc, userId))
          .toList();
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<AccountModel> addAccount(AccountModel account) async {
    try {
      final docRef = await _collection(account.userId).add(account.toFirestore());
      final doc = await docRef.get();
      return AccountModel.fromFirestore(doc, account.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<AccountModel> updateAccount(AccountModel account) async {
    try {
      await _collection(account.userId)
          .doc(account.id)
          .update(account.toFirestore());
      final doc = await _collection(account.userId).doc(account.id).get();
      return AccountModel.fromFirestore(doc, account.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteAccount(String userId, String accountId) async {
    try {
      await _collection(userId).doc(accountId).update({'isActive': false});
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> updateBalance(String userId, String accountId, int newBalance) async {
    try {
      await _collection(userId).doc(accountId).update({'balance': newBalance});
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> recalculateBalances(String userId) async {
    try {
      final accounts = await getAccounts(userId);
      final txSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('isDeleted', isEqualTo: false)
          .get();

      final deltas = <String, int>{};
      for (final doc in txSnapshot.docs) {
        final data = doc.data();
        final accountId = data['accountId'] as String? ?? '';
        final amount = (data['amount'] as num?)?.toInt() ?? 0;
        final type = data['type'] as String? ?? '';
        if (type == 'income') {
          deltas[accountId] = (deltas[accountId] ?? 0) + amount;
        } else if (type == 'expense') {
          deltas[accountId] = (deltas[accountId] ?? 0) - amount;
        }
      }

      final batch = _firestore.batch();
      for (final account in accounts) {
        final correct = account.initialBalance + (deltas[account.id] ?? 0);
        batch.update(_collection(userId).doc(account.id), {'balance': correct});
      }
      await batch.commit();
    } catch (_) {
      throw const ServerException();
    }
  }
}
