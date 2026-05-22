import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.icon,
    required super.color,
    super.isDefault,
    required super.createdAt,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      userId: userId,
      name: data['name'] as String,
      type: TransactionTypeExtension.fromString(data['type'] as String? ?? 'expense'),
      icon: data['icon'] as String? ?? 'category',
      color: data['color'] as String? ?? '#94A3B8',
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.firestoreValue,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
