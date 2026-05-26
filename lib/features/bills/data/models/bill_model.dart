import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bill_entity.dart';

class BillModel extends BillEntity {
  const BillModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.dueDate,
    required super.categoryId,
    required super.accountId,
    super.isPaid,
    super.paidAt,
    super.isRecurring,
    super.recurringDay,
    super.notes,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.categoryName,
    super.categoryColor,
    super.accountName,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      userId: userId,
      name: data['name'] as String? ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      categoryId: data['categoryId'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      isPaid: data['isPaid'] as bool? ?? false,
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurringDay: data['recurringDay'] as int?,
      notes: data['notes'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      categoryName: data['categoryName'] as String?,
      categoryColor: data['categoryColor'] as String?,
      accountName: data['accountName'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'categoryId': categoryId,
      'accountId': accountId,
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'isRecurring': isRecurring,
      'recurringDay': recurringDay,
      'notes': notes,
      'isActive': isActive,
      'categoryName': categoryName,
      'categoryColor': categoryColor,
      'accountName': accountName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
