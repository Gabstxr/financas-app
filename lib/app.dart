import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'features/accounts/presentation/bloc/accounts_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/categories/presentation/bloc/categories_bloc.dart';
import 'features/transactions/presentation/bloc/transactions_bloc.dart';
import 'injection/injection_container.dart';
import 'router/app_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final AccountsBloc _accountsBloc;
  late final CategoriesBloc _categoriesBloc;
  late final TransactionsBloc _transactionsBloc;
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR');

    _authBloc = sl<AuthBloc>()..add(AuthCheckRequested());
    _accountsBloc = sl<AccountsBloc>();
    _categoriesBloc = sl<CategoriesBloc>();
    _transactionsBloc = sl<TransactionsBloc>();
    _router = AppRouter.router(_authBloc);

    // Carrega contas e categorias quando o usuário autentica.
    _authSub = _authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        _accountsBloc.add(AccountsLoadRequested(state.user.uid));
        _categoriesBloc.add(CategoriesLoadRequested(state.user.uid));
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authBloc.close();
    _accountsBloc.close();
    _categoriesBloc.close();
    _transactionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _accountsBloc),
        BlocProvider.value(value: _categoriesBloc),
        BlocProvider.value(value: _transactionsBloc),
      ],
      child: MaterialApp.router(
        title: 'FinançasApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: _router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
