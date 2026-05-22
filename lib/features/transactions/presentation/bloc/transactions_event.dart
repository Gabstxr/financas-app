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
  final TransactionEntity transaction;
  const TransactionsUpdateRequested(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class TransactionsDeleteRequested extends TransactionsEvent {
  final String userId;
  final String transactionId;
  const TransactionsDeleteRequested({required this.userId, required this.transactionId});
  @override
  List<Object> get props => [userId, transactionId];
}
