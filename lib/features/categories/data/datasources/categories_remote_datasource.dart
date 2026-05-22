import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/category_entity.dart';
import '../models/category_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String userId);
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<void> deleteCategory(String userId, String categoryId);
  Future<void> seedDefaultCategories(String userId);
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final FirebaseFirestore _firestore;

  const CategoriesRemoteDataSourceImpl(this._firestore);

  CollectionReference _collection(String userId) =>
      _firestore.collection('users').doc(userId).collection('categories');

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final snapshot = await _collection(userId).orderBy('name').get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc, userId))
          .toList();
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final docRef = await _collection(category.userId).add(category.toFirestore());
      final doc = await docRef.get();
      return CategoryModel.fromFirestore(doc, category.userId);
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _collection(userId).doc(categoryId).delete();
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<void> seedDefaultCategories(String userId) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      for (final cat in DefaultCategories.expense(userId)) {
        final docRef = _collection(userId).doc();
        batch.set(docRef, {
          ...cat,
          'isDefault': true,
          'createdAt': Timestamp.fromDate(now),
        });
      }

      for (final cat in DefaultCategories.income(userId)) {
        final docRef = _collection(userId).doc();
        batch.set(docRef, {
          ...cat,
          'isDefault': true,
          'createdAt': Timestamp.fromDate(now),
        });
      }

      await batch.commit();
    } catch (_) {
      throw const ServerException();
    }
  }
}
