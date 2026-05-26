part of 'transactions_bloc.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
  @override
  List<Object?> get props => [];
}

class TransactionsLoadRequested extends TransactionsEvent {
  final String userId;
  final int year;
  final int month;
  const TransactionsLoadRequested({required this.userId, required this.year, required this.month});
  @override
  List<Object> get props => [userId, year, month];
}

class TransactionsAddRequested extends TransactionsEvent {
  final TransactionEntity transaction;
  const TransactionsAddRequested(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class TransactionsUpdateRequested extends TransactionsEvent {
  final TransactionEntity oldTransaction;
  final TransactionEntity transaction;
  const TransactionsUpdateRequested({
    required this.oldTransaction,
    required this.transaction,
  });
  @override
  List<Object> get props => [oldTransaction, transaction];
}

class TransactionsDeleteRequested extends TransactionsEvent {
  final TransactionEntity transaction;
  const TransactionsDeleteRequested(this.transaction);
  @override
  List<Object> get props => [transaction];
}
