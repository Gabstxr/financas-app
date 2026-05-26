import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/planning_entity.dart';
import '../repositories/planning_repository.dart';

class GetPlanning {
  final PlanningRepository repository;
  const GetPlanning(this.repository);

  Future<Either<Failure, PlanningEntity?>> call(String userId, String monthId) {
    return repository.getPlanning(userId, monthId);
  }
}
