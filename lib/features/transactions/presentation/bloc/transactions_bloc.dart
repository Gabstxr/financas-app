import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions_by_month.dart';
import '../../domain/usecases/update_transaction.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetTransactionsByMonth getTransactionsByMonth;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final AccountsBloc accountsBloc;
  final DashboardCubit dashboardCubit;

  TransactionsBloc({
    required this.getTransactionsByMonth,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.accountsBloc,
    required this.dashboardCubit,
  }) : super(TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onLoad);
    on<TransactionsAddRequested>(_onAdd);
    on<TransactionsUpdateRequested>(_onUpdate);
    on<TransactionsDeleteRequested>(_onDelete);
  }

  void _reloadDashboard(String userId) {
    final currentMonth = dashboardCubit.state is DashboardLoaded
        ? (dashboardCubit.state as DashboardLoaded).currentMonth
        : null;
    dashboardCubit.load(userId, month: currentMonth);
  }

  Future<void> _onLoad(TransactionsLoadRequested event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    final result = await getTransactionsByMonth(event.userId, event.year, event.month);
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (transactions) => emit(TransactionsLoaded(
        transactions: transactions,
        year: event.year,
        month: event.month,
      )),
    );
  }

  Future<void> _onAdd(TransactionsAddRequested event, Emitter<TransactionsState> emit) async {
    final result = await addTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (transaction) {
        accountsBloc.add(AccountsLoadRequested(transaction.userId));
        _reloadDashboard(transaction.userId);

        if (state is TransactionsLoaded) {
          final current = state as TransactionsLoaded;
          final sameMonth = transaction.date.year == current.year &&
              transaction.date.month == current.month;
          if (sameMonth) {
            final updated = [transaction, ...current.transactions];
            updated.sort((a, b) => b.date.compareTo(a.date));
            emit(current.copyWith(transactions: updated));
          }
        }
      },
    );
  }

  Future<void> _onUpdate(
      TransactionsUpdateRequested event, Emitter<TransactionsState> emit) async {
    if (state is! TransactionsLoaded) return;
    final current = state as TransactionsLoaded;

    final result = await updateTransaction(event.oldTransaction, event.transaction);
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (updated) {
        accountsBloc.add(AccountsLoadRequested(updated.userId));
        _reloadDashboard(updated.userId);
        final transactions = current.transactions
            .map((t) => t.id == updated.id ? updated : t)
            .toList();
        emit(current.copyWith(transactions: transactions));
      },
    );
  }

  Future<void> _onDelete(
      TransactionsDeleteRequested event, Emitter<TransactionsState> emit) async {
    if (state is! TransactionsLoaded) return;
    final current = state as TransactionsLoaded;

    final result = await deleteTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (_) {
        accountsBloc.add(AccountsLoadRequested(event.transaction.userId));
        _reloadDashboard(event.transaction.userId);
        final transactions = current.transactions
            .where((t) => t.id != event.transaction.id)
            .toList();
        emit(current.copyWith(transactions: transactions));
      },
    );
  }
}
