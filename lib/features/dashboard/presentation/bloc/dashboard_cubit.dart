import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/domain/usecases/get_accounts.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/usecases/get_transactions_by_month.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetTransactionsByMonth getTransactionsByMonth;
  final GetAccounts getAccounts;

  DashboardCubit({
    required this.getTransactionsByMonth,
    required this.getAccounts,
  }) : super(DashboardInitial());

  Future<void> load(String userId, {DateTime? month}) async {
    emit(DashboardLoading());

    final targetMonth = month ?? DateTime.now();

    final accountsResult = await getAccounts(userId);
    final transactionsResult = await getTransactionsByMonth(
      userId,
      targetMonth.year,
      targetMonth.month,
    );

    accountsResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (accounts) {
        transactionsResult.fold(
          (failure) => emit(DashboardError(failure.message)),
          (transactions) => emit(DashboardLoaded(
            accounts: accounts,
            transactions: transactions,
            currentMonth: targetMonth,
          )),
        );
      },
    );
  }

  void changeMonth(String userId, DateTime month) {
    load(userId, month: month);
  }
}
