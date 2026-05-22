part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}
class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<TransactionEntity> transactions;
  final DateTime currentMonth;

  const ReportsLoaded({required this.transactions, required this.currentMonth});

  int get totalIncome => transactions
      .where((t) => t.type == FullTransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalExpenses => transactions
      .where((t) => t.type == FullTransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  /// Agrupa despesas por categoria e retorna mapa {categoryName: totalCents}
  Map<String, int> get expensesByCategory {
    final map = <String, int>{};
    for (final t in transactions.where((t) => t.isExpense)) {
      final key = t.categoryName ?? 'Outros';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
    return sorted;
  }

  Map<String, int> get incomeByCategory {
    final map = <String, int>{};
    for (final t in transactions.where((t) => t.isIncome)) {
      final key = t.categoryName ?? 'Outros';
      map[key] = (map[key] ?? 0) + t.amount;
    }
    return map;
  }

  @override
  List<Object> get props => [transactions, currentMonth];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object> get props => [message];
}
