import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/planning_entity.dart';

class PlanningModel extends PlanningEntity {
  const PlanningModel({
    required super.id,
    required super.userId,
    required super.salary,
    required super.fixedExpenses,
    required super.savingsGoalPercent,
    required super.categoryLimits,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PlanningModel.fromFirestore(DocumentSnapshot doc, String userId) {
    final data = doc.data() as Map<String, dynamic>;
    final rawLimits = data['categoryLimits'] as Map<String, dynamic>? ?? {};
    return PlanningModel(
      id: doc.id,
      userId: userId,
      salary: (data['salary'] as num?)?.toInt() ?? 0,
      fixedExpenses: (data['fixedExpenses'] as num?)?.toInt() ?? 0,
      savingsGoalPercent: (data['savingsGoalPercent'] as num?)?.toInt() ?? 20,
      categoryLimits: rawLimits.map((k, v) => MapEntry(k, (v as num).toInt())),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'salary': salary,
      'fixedExpenses': fixedExpenses,
      'savingsGoalPercent': savingsGoalPercent,
      'categoryLimits': categoryLimits,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory PlanningModel.fromEntity(PlanningEntity entity) {
    return PlanningModel(
      id: entity.id,
      userId: entity.userId,
      salary: entity.salary,
      fixedExpenses: entity.fixedExpenses,
      savingsGoalPercent: entity.savingsGoalPercent,
      categoryLimits: entity.categoryLimits,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
