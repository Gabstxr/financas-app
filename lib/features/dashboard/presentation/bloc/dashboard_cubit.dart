import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/domain/usecases/get_accounts.dart';
import '../../../bills/domain/entities/bill_entity.dart';
import '../../../bills/domain/usecases/get_bills.dart';
import '../../../planning/domain/entities/planning_entity.dart';
import '../../../planning/domain/usecases/get_planning.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/usecases/get_transactions_by_month.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetTransactionsByMonth getTransactionsByMonth;
  final GetAccounts getAccounts;
  final GetPlanning getPlanning;
  final GetBills getBills;

  DashboardCubit({
    required this.getTransactionsByMonth,
    required this.getAccounts,
    required this.getPlanning,
    required this.getBills,
  }) : super(DashboardInitial());

  Future<void> load(String userId, {DateTime? month}) async {
    emit(DashboardLoading());

    final targetMonth = month ?? DateTime.now();
    final monthId =
        '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}';

    final accountsResult = await getAccounts(userId);
    final transactionsResult = await getTransactionsByMonth(
      userId,
      targetMonth.year,
      targetMonth.month,
    );
    final planningResult = await getPlanning(userId, monthId);
    final billsResult = await getBills(userId);

    List<AccountEntity>? accounts;
    List<TransactionEntity>? transactions;
    PlanningEntity? planning;
    List<BillEntity> bills = [];

    accountsResult.fold((f) => null, (v) => accounts = v);
    transactionsResult.fold((f) => null, (v) => transactions = v);
    planningResult.fold((f) => null, (v) => planning = v);
    billsResult.fold((f) => null, (v) => bills = v);

    if (accounts == null || transactions == null) {
      final msg = accountsResult.isLeft()
          ? (accountsResult as dynamic).value.message
          : (transactionsResult as dynamic).value.message;
      emit(DashboardError(msg ?? 'Erro ao carregar dados'));
      return;
    }

    emit(DashboardLoaded(
      accounts: accounts!,
      transactions: transactions!,
      planning: planning,
      bills: bills,
      currentMonth: targetMonth,
    ));
  }

  void changeMonth(String userId, DateTime month) {
    load(userId, month: month);
  }
}
