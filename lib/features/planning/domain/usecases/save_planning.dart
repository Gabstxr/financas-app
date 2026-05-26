import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/planning_entity.dart';
import '../repositories/planning_repository.dart';

class SavePlanning {
  final PlanningRepository repository;
  const SavePlanning(this.repository);

  Future<Either<Failure, PlanningEntity>> call(PlanningEntity planning) {
    return repository.savePlanning(planning);
  }
}
