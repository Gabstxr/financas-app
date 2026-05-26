import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/planning_entity.dart';
import '../../domain/repositories/planning_repository.dart';
import '../datasources/planning_remote_datasource.dart';
import '../models/planning_model.dart';

class PlanningRepositoryImpl implements PlanningRepository {
  final PlanningRemoteDataSource _dataSource;

  const PlanningRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, PlanningEntity?>> getPlanning(
      String userId, String monthId) async {
    try {
      final planning = await _dataSource.getPlanning(userId, monthId);
      return Right(planning);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PlanningEntity>> savePlanning(
      PlanningEntity planning) async {
    try {
      final model = PlanningModel.fromEntity(planning);
      final result = await _dataSource.savePlanning(model);
      return Right(result);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
