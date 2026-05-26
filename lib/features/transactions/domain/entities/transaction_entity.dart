import 'package:equatable/equatable.dart';

enum FullTransactionType { income, expense, transfer }

extension FullTransactionTypeExtension on FullTransactionType {
  String get firestoreValue => name;
  static FullTransactionType fromString(String value) {
    return FullTransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FullTransactionType.expense,
    );
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final FullTransactionType type;
  final int amount;
  final String description;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final DateTime date;
  final bool isRecurring;
  final String? recurrenceId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  // Desnormalizado para exibição (não persiste separado)
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? accountName;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.date,
    this.isRecurring = false,
    this.recurrenceId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.accountName,
  });

  TransactionEntity copyWith({
    String? id,
    String? userId,
    FullTransactionType? type,
    int? amount,
    String? description,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    bool? isRecurring,
    String? recurrenceId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? accountName,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceId: recurrenceId ?? this.recurrenceId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      accountName: accountName ?? this.accountName,
    );
  }

  bool get isIncome => type == FullTransactionType.income;
  bool get isExpense => type == FullTransactionType.expense;
  bool get isTransfer => type == FullTransactionType.transfer;

  @override
  List<Object?> get props => [id, userId, type, amount, description, categoryId, accountId, date];
}
