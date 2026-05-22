import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoriesRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories(String userId);
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String userId, String categoryId);
  Future<Either<Failure, void>> seedDefaultCategories(String userId);
}
