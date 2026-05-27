import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/transactions/presentation/pages/add_transaction_page.dart';
import '../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../features/transactions/presentation/pages/transaction_list_page.dart';
import '../features/accounts/presentation/pages/accounts_page.dart';
import '../features/accounts/presentation/pages/add_account_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/categories/presentation/pages/add_category_page.dart';
import '../features/bills/presentation/pages/bills_page.dart';
import '../features/planning/presentation/pages/planning_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/accounts/domain/entities/account_entity.dart';
import '../features/transactions/domain/entities/transaction_entity.dart';
import 'main_scaffold.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const transactions = '/transactions';
  static const addTransaction = '/add-transaction';
  static const editTransaction = '/edit-transaction';
  static const transactionDetail = '/transaction-detail';
  static const accounts = '/accounts';
  static const addAccount = '/add-account';
  static const editAccount = '/edit-account';
  static const categories = '/categories';
  static const addCategory = '/add-category';
  static const reports = '/reports';
  static const planning = '/planning';
  static const bills = '/bills';
  static const settings = '/settings';
}

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterAuthStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isLoading = authState is AuthLoading || authState is AuthInitial;
        final needsOnboarding = authState is AuthAuthenticated && !authState.user.onboardingDone;

        final isOnAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register;
        final isOnSplash = state.matchedLocation == AppRoutes.splash;
        final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

        if (isLoading) return AppRoutes.splash;
        if (!isAuthenticated && !isOnAuthRoute) return AppRoutes.login;
        if (isAuthenticated && needsOnboarding && !isOnOnboarding) return AppRoutes.onboarding;
        if (isAuthenticated && !needsOnboarding && (isOnAuthRoute || isOnSplash || isOnOnboarding)) {
          return AppRoutes.dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
        GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
        GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingPage()),
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              pageBuilder: (_, __) => const NoTransitionPage(child: DashboardPage()),
            ),
            GoRoute(
              path: AppRoutes.transactions,
              pageBuilder: (_, __) => const NoTransitionPage(child: TransactionListPage()),
            ),
            GoRoute(
              path: AppRoutes.reports,
              pageBuilder: (_, __) => const NoTransitionPage(child: ReportsPage()),
            ),
            GoRoute(
              path: AppRoutes.planning,
              pageBuilder: (_, __) => const NoTransitionPage(child: PlanningPage()),
            ),
            GoRoute(
              path: AppRoutes.settings,
              pageBuilder: (_, __) => const NoTransitionPage(child: SettingsPage()),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.addTransaction,
          builder: (_, state) => AddTransactionPage(transaction: state.extra as TransactionEntity?),
        ),
        GoRoute(
          path: AppRoutes.transactionDetail,
          builder: (_, state) => TransactionDetailPage(transaction: state.extra as TransactionEntity),
        ),
        GoRoute(
          path: AppRoutes.accounts,
          builder: (_, __) => const AccountsPage(),
        ),
        GoRoute(
          path: AppRoutes.addAccount,
          builder: (_, state) => AddAccountPage(account: state.extra as AccountEntity?),
        ),
        GoRoute(
          path: AppRoutes.categories,
          builder: (_, __) => const CategoriesPage(),
        ),
        GoRoute(
          path: AppRoutes.addCategory,
          builder: (_, __) => const AddCategoryPage(),
        ),
        GoRoute(
          path: AppRoutes.bills,
          builder: (_, __) => const BillsPage(),
        ),
      ],
    );
  }
}

class GoRouterAuthStream extends ChangeNotifier {
  GoRouterAuthStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
