import '../../features/categories/domain/entities/category_entity.dart';
import '../../features/planning/domain/entities/planning_entity.dart';

class PlanningEngine {
  static const Map<String, KakeiboPillar> _categoryPillarMap = {
    'Alimentação': KakeiboPillar.sobrevivencia,
    'Transporte': KakeiboPillar.sobrevivencia,
    'Moradia': KakeiboPillar.sobrevivencia,
    'Saúde': KakeiboPillar.sobrevivencia,
    'Lazer': KakeiboPillar.opcional,
    'Vestuário': KakeiboPillar.opcional,
    'Assinaturas': KakeiboPillar.opcional,
    'Educação': KakeiboPillar.cultura,
    'Pets': KakeiboPillar.imprevistos,
    'Outros': KakeiboPillar.imprevistos,
  };

  static KakeiboPillar pillarForCategory(String categoryName) =>
      _categoryPillarMap[categoryName] ?? KakeiboPillar.opcional;

  static Map<KakeiboPillar, List<CategoryEntity>> groupByPillar(
    List<CategoryEntity> expenseCategories,
  ) {
    final result = <KakeiboPillar, List<CategoryEntity>>{
      for (final p in KakeiboPillar.values) p: [],
    };
    for (final cat in expenseCategories) {
      result[pillarForCategory(cat.name)]!.add(cat);
    }
    return result;
  }

  static Map<String, int> suggestLimits(
    List<CategoryEntity> expenseCategories,
    int spendingBudget,
  ) {
    if (spendingBudget <= 0) {
      return {for (final cat in expenseCategories) cat.id: 0};
    }

    final grouped = groupByPillar(expenseCategories);
    final result = <String, int>{};

    for (final pillar in KakeiboPillar.values) {
      final categories = grouped[pillar]!;
      if (categories.isEmpty) continue;
      final pillarBudget = (spendingBudget * pillar.suggestedPercent).round();
      final perCat = pillarBudget ~/ categories.length;
      for (final cat in categories) {
        result[cat.id] = perCat;
      }
    }

    return result;
  }

  static List<SpendingInsight> generateInsights({
    required PlanningEntity plan,
    required Map<String, int> spentByCategory,
    required List<CategoryEntity> categories,
    required int totalIncome,
  }) {
    final insights = <SpendingInsight>[];
    final categoryMap = {for (final c in categories) c.id: c};

    for (final entry in plan.categoryLimits.entries) {
      final spent = spentByCategory[entry.key] ?? 0;
      final limit = entry.value;
      if (limit <= 0) continue;

      final progress = spent / limit;
      final catName = categoryMap[entry.key]?.name ?? 'Categoria';

      if (progress >= 1.0) {
        insights.add(SpendingInsight(
          type: InsightType.alert,
          title: 'Limite ultrapassado',
          message: '$catName passou 100% do limite planejado.',
          categoryId: entry.key,
          progressPercent: progress,
        ));
      } else if (progress >= 0.8) {
        insights.add(SpendingInsight(
          type: InsightType.warning,
          title: 'Atenção: $catName',
          message: '$catName atingiu ${(progress * 100).round()}% do limite.',
          categoryId: entry.key,
          progressPercent: progress,
        ));
      }
    }

    final totalSpent = spentByCategory.values.fold(0, (a, b) => a + b);
    final savingsAchieved = totalIncome - totalSpent;

    if (savingsAchieved >= plan.savingsGoal && plan.savingsGoal > 0) {
      insights.insert(
        0,
        const SpendingInsight(
          type: InsightType.praise,
          title: 'Meta de economia atingida!',
          message: 'Você está no caminho certo. Continue assim!',
          progressPercent: 1.0,
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(_getKakeiboTip(plan, totalSpent, totalIncome));
    }

    return insights;
  }

  static SpendingInsight _getKakeiboTip(
    PlanningEntity plan,
    int totalSpent,
    int totalIncome,
  ) {
    if (totalIncome == 0) {
      return const SpendingInsight(
        type: InsightType.tip,
        title: 'Registre sua renda',
        message:
            'Para um planejamento preciso, lembre-se de registrar suas receitas do mês.',
      );
    }

    final spendPercent =
        plan.spendingBudget > 0 ? totalSpent / plan.spendingBudget : 0.0;

    if (spendPercent < 0.5) {
      return const SpendingInsight(
        type: InsightType.tip,
        title: 'Ótimo início de mês!',
        message: 'Pergunta Kakeibo: quanto você quer economizar este mês?',
      );
    }

    if (spendPercent > 0.9) {
      return const SpendingInsight(
        type: InsightType.tip,
        title: 'Fique atento',
        message:
            'Você está próximo do limite do mês. Reveja gastos opcionais antes de novas compras.',
      );
    }

    return const SpendingInsight(
      type: InsightType.tip,
      title: 'Reflexão Kakeibo',
      message: 'Antes de cada compra: isso é necessidade ou desejo?',
    );
  }
}
