import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/auth/domain/entities/user_entity.dart';
import 'package:financas_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:financas_app/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:financas_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:financas_app/features/auth/domain/usecases/sign_out.dart';
import 'package:financas_app/features/auth/domain/usecases/sign_up.dart';
import 'package:financas_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInWithEmail extends Mock implements SignInWithEmail {}
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}
class MockSignUp extends Mock implements SignUp {}
class MockSignOut extends Mock implements SignOut {}
class MockAuthRepository extends Mock implements AuthRepository {}

final _tUser = UserEntity(
  uid: 'uid-123',
  email: 'test@test.com',
  displayName: 'Test User',
  onboardingDone: true,
  createdAt: DateTime(2025),
);

void main() {
  late AuthBloc bloc;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    bloc = AuthBloc(
      signInWithEmail: mockSignInWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      signUp: mockSignUp,
      signOut: mockSignOut,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() => bloc.close());

  group('AuthSignInWithEmailRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] quando login tem sucesso',
      build: () {
        when(() => mockSignInWithEmail('test@test.com', '123456'))
            .thenAnswer((_) async => Right(_tUser));
        return bloc;
      },
      act: (b) => b.add(const AuthSignInWithEmailRequested(
          email: 'test@test.com', password: '123456')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthError] quando login falha',
      build: () {
        when(() => mockSignInWithEmail(any(), any()))
            .thenAnswer((_) async => const Left(AuthFailure()));
        return bloc;
      },
      act: (b) => b.add(const AuthSignInWithEmailRequested(
          email: 'wrong@test.com', password: 'wrong')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('AuthSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthAuthenticated] quando cadastro tem sucesso',
      build: () {
        when(() => mockSignUp(any(), any(), any()))
            .thenAnswer((_) async => Right(_tUser));
        return bloc;
      },
      act: (b) => b.add(const AuthSignUpRequested(
          email: 'new@test.com', password: '123456', name: 'Novo User')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [AuthLoading, AuthError] quando e-mail já existe',
      build: () {
        when(() => mockSignUp(any(), any(), any()))
            .thenAnswer((_) async => const Left(EmailAlreadyInUseFailure()));
        return bloc;
      },
      act: (b) => b.add(const AuthSignUpRequested(
          email: 'exists@test.com', password: '123456', name: 'User')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emite [AuthUnauthenticated] após logout',
      build: () {
        when(() => mockSignOut())
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) => b.add(AuthSignOutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );
  });
}
