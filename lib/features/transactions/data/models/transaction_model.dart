import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.description,
    required super.categoryId,
    required super.accountId,
    super.toAccountId,
    required super.date,
    super.isRecurring,
    super.recurrenceId,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    super.accountName,
    super.toAccountName,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: userId,
      type: FullTransactionTypeExtension.fromString(data['type'] as String? ?? 'expense'),
      amount: (data['amount'] as num).toInt(),
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      toAccountId: data['toAccountId'] as String?,
      date: (data['date'] as Timestamp).toDate(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurrenceId: data['recurrenceId'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] as bool? ?? false,
      categoryName: data['categoryName'] as String?,
      categoryIcon: data['categoryIcon'] as String?,
      categoryColor: data['categoryColor'] as String?,
      accountName: data['accountName'] as String?,
      toAccountName: data['toAccountName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.firestoreValue,
      'amount': amount,
      'description': description,
      'categoryId': categoryId,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'recurrenceId': recurrenceId,
      'notes': notes,
      'isDeleted': isDeleted,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'accountName': accountName,
      'toAccountName': toAccountName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
