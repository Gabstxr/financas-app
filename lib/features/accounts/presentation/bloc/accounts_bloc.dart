import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/usecases/add_account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_accounts.dart';
import '../../domain/usecases/recalculate_balances.dart';
import '../../domain/usecases/update_account.dart';

part 'accounts_event.dart';
part 'accounts_state.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final GetAccounts getAccounts;
  final AddAccount addAccount;
  final UpdateAccount updateAccount;
  final DeleteAccount deleteAccount;
  final RecalculateBalances recalculateBalances;

  AccountsBloc({
    required this.getAccounts,
    required this.addAccount,
    required this.updateAccount,
    required this.deleteAccount,
    required this.recalculateBalances,
  }) : super(AccountsInitial()) {
    on<AccountsLoadRequested>(_onLoad);
    on<AccountsAddRequested>(_onAdd);
    on<AccountsUpdateRequested>(_onUpdate);
    on<AccountsDeleteRequested>(_onDelete);
    on<AccountsRecalculateRequested>(_onRecalculate);
  }

  Future<void> _onLoad(AccountsLoadRequested event, Emitter<AccountsState> emit) async {
    emit(AccountsLoading());
    final result = await getAccounts(event.userId);
    result.fold(
      (failure) => emit(AccountsError(failure.message)),
      (accounts) => emit(AccountsLoaded(accounts)),
    );
  }

  Future<void> _onAdd(AccountsAddRequested event, Emitter<AccountsState> emit) async {
    final currentAccounts = state is AccountsLoaded
        ? (state as AccountsLoaded).accounts
        : <AccountEntity>[];

    final result = await addAccount(event.account);
    result.fold(
      (failure) => emit(AccountsError(failure.message)),
      (account) => emit(AccountsLoaded([...currentAccounts, account])),
    );
  }

  Future<void> _onUpdate(AccountsUpdateRequested event, Emitter<AccountsState> emit) async {
    if (state is! AccountsLoaded) return;
    final currentAccounts = (state as AccountsLoaded).accounts;

    final result = await updateAccount(event.account);
    result.fold(
      (failure) => emit(AccountsError(failure.message)),
      (updated) {
        final accounts = currentAccounts
            .map((a) => a.id == updated.id ? updated : a)
            .toList();
        emit(AccountsLoaded(accounts));
      },
    );
  }

  Future<void> _onDelete(AccountsDeleteRequested event, Emitter<AccountsState> emit) async {
    if (state is! AccountsLoaded) return;
    final currentAccounts = (state as AccountsLoaded).accounts;

    final result = await deleteAccount(event.userId, event.accountId);
    result.fold(
      (failure) => emit(AccountsError(failure.message)),
      (_) {
        final accounts = currentAccounts
            .where((a) => a.id != event.accountId)
            .toList();
        emit(AccountsLoaded(accounts));
      },
    );
  }

  Future<void> _onRecalculate(AccountsRecalculateRequested event, Emitter<AccountsState> emit) async {
    final result = await recalculateBalances(event.userId);
    result.fold(
      (failure) => emit(AccountsError(failure.message)),
      (_) => add(AccountsLoadRequested(event.userId)),
    );
  }
}
