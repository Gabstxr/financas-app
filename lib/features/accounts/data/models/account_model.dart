import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.balance,
    required super.initialBalance,
    required super.color,
    required super.icon,
    super.isActive,
    required super.createdAt,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      userId: userId,
      name: data['name'] as String,
      type: AccountTypeExtension.fromString(data['type'] as String? ?? 'checking'),
      balance: (data['balance'] as num).toInt(),
      initialBalance: (data['initialBalance'] as num).toInt(),
      color: data['color'] as String? ?? '#7C3AED',
      icon: data['icon'] as String? ?? 'account_balance_wallet',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.firestoreValue,
      'balance': balance,
      'initialBalance': initialBalance,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
