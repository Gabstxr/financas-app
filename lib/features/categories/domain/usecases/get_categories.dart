import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/categories_repository.dart';

class GetCategories {
  final CategoriesRepository repository;
  const GetCategories(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call(String userId) {
    return repository.getCategories(userId);
  }
}
