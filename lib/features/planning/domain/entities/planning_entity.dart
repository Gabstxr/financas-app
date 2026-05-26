import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum KakeiboPillar { sobrevivencia, opcional, cultura, imprevistos }

extension KakeiboPillarExtension on KakeiboPillar {
  String get label => switch (this) {
        KakeiboPillar.sobrevivencia => 'Sobrevivência',
        KakeiboPillar.opcional => 'Opcional',
        KakeiboPillar.cultura => 'Cultura',
        KakeiboPillar.imprevistos => 'Imprevistos',
      };

  double get suggestedPercent => switch (this) {
        KakeiboPillar.sobrevivencia => 0.50,
        KakeiboPillar.opcional => 0.30,
        KakeiboPillar.cultura => 0.10,
        KakeiboPillar.imprevistos => 0.10,
      };

  Color get color => switch (this) {
        KakeiboPillar.sobrevivencia => const Color(0xFF10B981),
        KakeiboPillar.opcional => const Color(0xFF3B82F6),
        KakeiboPillar.cultura => const Color(0xFF8B5CF6),
        KakeiboPillar.imprevistos => const Color(0xFFF59E0B),
      };

  IconData get icon => switch (this) {
        KakeiboPillar.sobrevivencia => Icons.home_outlined,
        KakeiboPillar.opcional => Icons.star_outline_rounded,
        KakeiboPillar.cultura => Icons.school_outlined,
        KakeiboPillar.imprevistos => Icons.warning_amber_outlined,
      };
}

enum InsightType { alert, warning, praise, tip }

class SpendingInsight extends Equatable {
  final InsightType type;
  final String title;
  final String message;
  final String? categoryId;
  final double? progressPercent;

  const SpendingInsight({
    required this.type,
    required this.title,
    required this.message,
    this.categoryId,
    this.progressPercent,
  });

  @override
  List<Object?> get props => [type, title, message, categoryId];
}

class PlanningEntity extends Equatable {
  final String id; // "YYYY-MM"
  final String userId;
  final int salary; // centavos
  final int fixedExpenses; // centavos
  final int savingsGoalPercent; // 0-50
  final Map<String, int> categoryLimits; // categoryId -> centavos
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanningEntity({
    required this.id,
    required this.userId,
    required this.salary,
    required this.fixedExpenses,
    required this.savingsGoalPercent,
    required this.categoryLimits,
    required this.createdAt,
    required this.updatedAt,
  });

  int get disposableIncome => salary - fixedExpenses;
  int get savingsGoal => (disposableIncome * savingsGoalPercent / 100).round();
  int get spendingBudget => disposableIncome - savingsGoal;

  PlanningEntity copyWith({
    String? id,
    String? userId,
    int? salary,
    int? fixedExpenses,
    int? savingsGoalPercent,
    Map<String, int>? categoryLimits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanningEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      salary: salary ?? this.salary,
      fixedExpenses: fixedExpenses ?? this.fixedExpenses,
      savingsGoalPercent: savingsGoalPercent ?? this.savingsGoalPercent,
      categoryLimits: categoryLimits ?? this.categoryLimits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        salary,
        fixedExpenses,
        savingsGoalPercent,
        categoryLimits,
      ];
}
