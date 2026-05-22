import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _dataSource;
  const CategoriesRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories(String userId) async {
    try {
      final categories = await _dataSource.getCategories(userId);
      return Right(categories);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category) async {
    try {
      final model = CategoryModel(
        id: category.id,
        userId: category.userId,
        name: category.name,
        type: category.type,
        icon: category.icon,
        color: category.color,
        isDefault: category.isDefault,
        createdAt: category.createdAt,
      );
      final result = await _dataSource.addCategory(model);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String userId, String categoryId) async {
    try {
      await _dataSource.deleteCategory(userId, categoryId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultCategories(String userId) async {
    try {
      await _dataSource.seedDefaultCategories(userId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
