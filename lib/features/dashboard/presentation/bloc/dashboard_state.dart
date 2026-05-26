part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<AccountEntity> accounts;
  final List<TransactionEntity> transactions;
  final PlanningEntity? planning;
  final List<BillEntity> bills;
  final DateTime currentMonth;

  const DashboardLoaded({
    required this.accounts,
    required this.transactions,
    this.planning,
    this.bills = const [],
    required this.currentMonth,
  });

  int get totalBalance => accounts.fold(0, (sum, a) => sum + a.balance);

  int get monthlyIncome => transactions
      .where((t) => t.type == FullTransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  int get monthlyExpenses => transactions
      .where((t) => t.type == FullTransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  Map<String, int> get spentByCategory {
    final map = <String, int>{};
    for (final t in transactions) {
      if (t.type == FullTransactionType.expense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  }

  List<TransactionEntity> get recentTransactions => transactions.take(5).toList();

  List<BillEntity> get pendingBills =>
      bills.where((b) => !b.isPaid && (b.isOverdue || b.isDueSoon)).toList();

  @override
  List<Object?> get props => [accounts, transactions, planning, bills, currentMonth];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object> get props => [message];
}
