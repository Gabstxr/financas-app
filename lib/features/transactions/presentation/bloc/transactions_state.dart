part of 'transactions_bloc.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();
  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}
class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionEntity> transactions;
  final int year;
  final int month;

  const TransactionsLoaded({
    required this.transactions,
    required this.year,
    required this.month,
  });

  int get totalIncome => transactions
      .where((t) => t.type == FullTransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  int get totalExpenses => transactions
      .where((t) => t.type == FullTransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  int get balance => totalIncome - totalExpenses;

  TransactionsLoaded copyWith({
    List<TransactionEntity>? transactions,
    int? year,
    int? month,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  @override
  List<Object> get props => [transactions, year, month];
}

class TransactionsError extends TransactionsState {
  final String message;
  const TransactionsError(this.message);
  @override
  List<Object> get props => [message];
}
