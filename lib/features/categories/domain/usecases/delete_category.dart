import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/categories_repository.dart';

class DeleteCategory {
  final CategoriesRepository repository;
  const DeleteCategory(this.repository);

  Future<Either<Failure, void>> call(String userId, String categoryId) {
    return repository.deleteCategory(userId, categoryId);
  }
}
