import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/planning_entity.dart';

abstract class PlanningRepository {
  Future<Either<Failure, PlanningEntity?>> getPlanning(String userId, String monthId);
  Future<Either<Failure, PlanningEntity>> savePlanning(PlanningEntity planning);
}
