import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signUp(String email, String password, String name);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> completeOnboarding(String uid);
  UserEntity? get currentUser;
}
