import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/categories_repository.dart';

class AddCategory {
  final CategoriesRepository repository;
  const AddCategory(this.repository);

  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) {
    return repository.addCategory(category);
  }
}
