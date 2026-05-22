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
  final DateTime currentMonth;

  const DashboardLoaded({
    required this.accounts,
    required this.transactions,
    required this.currentMonth,
  });

  int get totalBalance => accounts.fold(0, (sum, a) => sum + a.balance);

  int get monthlyIncome => transactions
      .where((t) => t.type == FullTransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  int get monthlyExpenses => transactions
      .where((t) => t.type == FullTransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  List<TransactionEntity> get recentTransactions => transactions.take(5).toList();

  @override
  List<Object> get props => [accounts, transactions, currentMonth];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object> get props => [message];
}
