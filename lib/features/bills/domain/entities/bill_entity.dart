import 'package:equatable/equatable.dart';

class BillEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final int amount;
  final DateTime dueDate;
  final String categoryId;
  final String accountId;
  final bool isPaid;
  final DateTime? paidAt;
  final bool isRecurring;
  final int? recurringDay;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Desnormalizado para exibição
  final String? categoryName;
  final String? categoryColor;
  final String? accountName;

  const BillEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.categoryId,
    required this.accountId,
    this.isPaid = false,
    this.paidAt,
    this.isRecurring = false,
    this.recurringDay,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryColor,
    this.accountName,
  });

  bool get isOverdue =>
      !isPaid && dueDate.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0));

  bool get isDueSoon {
    if (isPaid) return false;
    final today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0);
    final diff = dueDate.difference(today).inDays;
    return diff >= 0 && diff <= 7;
  }

  BillEntity copyWith({
    String? id,
    String? userId,
    String? name,
    int? amount,
    DateTime? dueDate,
    String? categoryId,
    String? accountId,
    bool? isPaid,
    DateTime? paidAt,
    bool? isRecurring,
    int? recurringDay,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryColor,
    String? accountName,
  }) {
    return BillEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDay: recurringDay ?? this.recurringDay,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      accountName: accountName ?? this.accountName,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, amount, dueDate, isPaid];
}
