import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/sign_in_with_email.dart';
import '../features/auth/domain/usecases/sign_in_with_google.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/domain/usecases/sign_up.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

import '../features/accounts/data/datasources/accounts_remote_datasource.dart';
import '../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../features/accounts/domain/repositories/accounts_repository.dart';
import '../features/accounts/domain/usecases/add_account.dart';
import '../features/accounts/domain/usecases/delete_account.dart';
import '../features/accounts/domain/usecases/get_accounts.dart';
import '../features/accounts/domain/usecases/recalculate_balances.dart';
import '../features/accounts/domain/usecases/update_account.dart';
import '../features/accounts/presentation/bloc/accounts_bloc.dart';

import '../features/categories/data/datasources/categories_remote_datasource.dart';
import '../features/categories/data/repositories/categories_repository_impl.dart';
import '../features/categories/domain/repositories/categories_repository.dart';
import '../features/categories/domain/usecases/add_category.dart';
import '../features/categories/domain/usecases/delete_category.dart';
import '../features/categories/domain/usecases/get_categories.dart';
import '../features/categories/presentation/bloc/categories_bloc.dart';

import '../features/transactions/data/datasources/transactions_remote_datasource.dart';
import '../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../features/transactions/domain/repositories/transactions_repository.dart';
import '../features/transactions/domain/usecases/add_transaction.dart';
import '../features/transactions/domain/usecases/delete_transaction.dart';
import '../features/transactions/domain/usecases/get_transactions_by_month.dart';
import '../features/transactions/domain/usecases/update_transaction.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';

import '../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../features/reports/presentation/bloc/reports_cubit.dart';

import '../features/planning/data/datasources/planning_remote_datasource.dart';
import '../features/planning/data/repositories/planning_repository_impl.dart';
import '../features/planning/domain/repositories/planning_repository.dart';
import '../features/planning/domain/usecases/get_planning.dart';
import '../features/planning/domain/usecases/save_planning.dart';
import '../features/planning/presentation/cubit/planning_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  try {
    await GoogleSignIn.instance.initialize();
  } catch (_) {
    // Google Play Services unavailable (emulator sem GMS) — Google Sign-In desativado
  }
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerFactory(() => AuthBloc(
        signInWithEmail: sl(),
        signInWithGoogle: sl(),
        signUp: sl(),
        signOut: sl(),
        authRepository: sl(),
      ));

  // Accounts
  sl.registerLazySingleton<AccountsRemoteDataSource>(
    () => AccountsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAccounts(sl()));
  sl.registerLazySingleton(() => AddAccount(sl()));
  sl.registerLazySingleton(() => UpdateAccount(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => RecalculateBalances(sl()));
  sl.registerLazySingleton(() => AccountsBloc(
        getAccounts: sl(),
        addAccount: sl(),
        updateAccount: sl(),
        deleteAccount: sl(),
        recalculateBalances: sl(),
      ));

  // Categories
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => AddCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerFactory(() => CategoriesBloc(
        getCategories: sl(),
        addCategory: sl(),
        deleteCategory: sl(),
      ));

  // Transactions
  sl.registerLazySingleton<TransactionsRemoteDataSource>(
    () => TransactionsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetTransactionsByMonth(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerFactory(() => TransactionsBloc(
        getTransactionsByMonth: sl(),
        addTransaction: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
        accountsBloc: sl(),
      ));

  // Dashboard & Reports
  sl.registerLazySingleton(() => DashboardCubit(
        getTransactionsByMonth: sl(),
        getAccounts: sl(),
        getPlanning: sl(),
      ));
  sl.registerFactory(() => ReportsCubit(
        getTransactionsByMonth: sl(),
      ));

  // Planning
  sl.registerLazySingleton<PlanningRemoteDataSource>(
    () => PlanningRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PlanningRepository>(
    () => PlanningRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetPlanning(sl()));
  sl.registerLazySingleton(() => SavePlanning(sl()));
  sl.registerFactory(() => PlanningCubit(
        getPlanning: sl(),
        savePlanning: sl(),
        getTransactionsByMonth: sl(),
        getCategories: sl(),
      ));
}
