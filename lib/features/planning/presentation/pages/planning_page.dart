import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/planning_engine.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../transactions/presentation/widgets/month_navigation_bar.dart';
import '../../domain/entities/planning_entity.dart';
import '../cubit/planning_cubit.dart';
import 'planning_setup_page.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  late final PlanningCubit _cubit;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _cubit = sl<PlanningCubit>();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.user.uid;
      _cubit.load(_userId!);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openSetup(PlanningLoaded state) {
    if (_userId == null) return;
    final authState = context.read<AuthBloc>().state;
    final defaultSalary =
        authState is AuthAuthenticated ? authState.user.salary : 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanningSetupPage(
          existing: state.planning,
          categories: state.categories,
          cubit: _cubit,
          userId: _userId!,
          month: state.currentMonth,
          defaultSalary: defaultSalary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlanningState>(
      stream: _cubit.stream,
      initialData: _cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _cubit.state;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Planejamento')),
          body: switch (state) {
            PlanningLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            PlanningError(:final message) =>
              Center(child: Text(message, style: AppTextStyles.bodyMedium)),
            PlanningLoaded() => _buildContent(state),
            _ => const SizedBox(),
          },
        );
      },
    );
  }

  Widget _buildContent(PlanningLoaded state) {
    return Column(
      children: [
        MonthNavigationBar(
          currentMonth: state.currentMonth,
          onPrevious: () {
            if (_userId == null) return;
            _cubit.changeMonth(
              _userId!,
              DateTime(state.currentMonth.year, state.currentMonth.month - 1),
            );
          },
          onNext: () {
            final now = DateTime.now();
            if (state.currentMonth.isBefore(DateTime(now.year, now.month))) {
              if (_userId == null) return;
              _cubit.changeMonth(
                _userId!,
                DateTime(
                    state.currentMonth.year, state.currentMonth.month + 1),
              );
            }
          },
        ),
        Expanded(
          child: state.planning == null
              ? _buildNoPlan(state)
              : _buildPlan(state),
        ),
      ],
    );
  }

  Widget _buildNoPlan(PlanningLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                size: 40,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text('Nenhum plano este mês', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Configure seu orçamento Kakeibo para acompanhar seus gastos e atingir suas metas.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.xl),
            FilledButton.icon(
              onPressed: () => _openSetup(state),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Configurar mês'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg, vertical: AppSizes.md),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlan(PlanningLoaded state) {
    final plan = state.planning!;
    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        _BudgetOverviewCard(state: state, plan: plan),
        const SizedBox(height: AppSizes.md),
        _KakeiboPillarsCard(state: state, plan: plan),
        const SizedBox(height: AppSizes.md),
        if (state.insights.isNotEmpty) ...[
          _InsightsSection(insights: state.insights),
          const SizedBox(height: AppSizes.md),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Por categoria', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: () => _openSetup(state),
              child: const Text('Editar plano'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        ...state.categories.map((cat) => _CategoryBudgetRow(
              category: cat,
              spent: state.spentByCategory[cat.id] ?? 0,
              limit: plan.categoryLimits[cat.id] ?? 0,
            )),
        const SizedBox(height: AppSizes.lg),
      ],
    );
  }
}

// ─── Budget Overview Card ────────────────────────────────────────────────────

class _BudgetOverviewCard extends StatelessWidget {
  final PlanningLoaded state;
  final PlanningEntity plan;

  const _BudgetOverviewCard({required this.state, required this.plan});

  @override
  Widget build(BuildContext context) {
    final savingsAchieved = (state.totalIncome - state.totalSpent)
        .clamp(0, double.maxFinite)
        .toInt();
    final goalAmount = plan.savingsGoal;
    final progress =
        goalAmount > 0 ? (savingsAchieved / goalAmount).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_outlined,
                  color: AppColors.income, size: 20),
              const SizedBox(width: AppSizes.xs),
              Text('Meta de economia', style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(savingsAchieved.toBRL,
                  style: AppTextStyles.amountMedium
                      .copyWith(color: AppColors.income)),
              const SizedBox(width: AppSizes.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('de ${goalAmount.toBRL}',
                    style: AppTextStyles.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: AppColors.income,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).round()}% atingido',
                  style: AppTextStyles.labelSmall),
              Text('Orçamento: ${plan.spendingBudget.toBRL}',
                  style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Kakeibo Pillars Card ────────────────────────────────────────────────────

class _KakeiboPillarsCard extends StatelessWidget {
  final PlanningLoaded state;
  final PlanningEntity plan;

  const _KakeiboPillarsCard({required this.state, required this.plan});

  @override
  Widget build(BuildContext context) {
    final grouped =
        PlanningEngine.groupByPillar(state.categories);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded,
                  color: AppColors.primaryLight, size: 20),
              const SizedBox(width: AppSizes.xs),
              Text('4 Pilares Kakeibo', style: AppTextStyles.labelMedium),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...KakeiboPillar.values.map((pillar) {
            final cats = grouped[pillar] ?? [];
            final spent = cats.fold<int>(
                0, (s, c) => s + (state.spentByCategory[c.id] ?? 0));
            final limit = cats.fold<int>(
                0, (s, c) => s + (plan.categoryLimits[c.id] ?? 0));
            final progress =
                limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
            final color = progress >= 1.0
                ? AppColors.expense
                : progress >= 0.8
                    ? AppColors.warning
                    : pillar.color;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(pillar.icon, color: pillar.color, size: 14),
                      const SizedBox(width: AppSizes.xs),
                      Expanded(
                          child: Text(pillar.label,
                              style: AppTextStyles.bodySmall)),
                      Text(
                        limit > 0 ? '${spent.toBRL} / ${limit.toBRL}' : spent.toBRL,
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: limit > 0 ? progress : 0,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Insights Section ────────────────────────────────────────────────────────

class _InsightsSection extends StatelessWidget {
  final List<SpendingInsight> insights;
  const _InsightsSection({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: insights
          .take(3)
          .map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: _InsightCard(insight: insight),
              ))
          .toList(),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final SpendingInsight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (insight.type) {
      InsightType.alert => (AppColors.expense, Icons.error_outline_rounded),
      InsightType.warning =>
        (AppColors.warning, Icons.warning_amber_rounded),
      InsightType.praise => (AppColors.income, Icons.celebration_rounded),
      InsightType.tip =>
        (AppColors.primaryLight, Icons.lightbulb_outline_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight.title,
                    style: AppTextStyles.labelLarge.copyWith(color: color)),
                const SizedBox(height: 2),
                Text(insight.message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Budget Row ─────────────────────────────────────────────────────

class _CategoryBudgetRow extends StatelessWidget {
  final CategoryEntity category;
  final int spent;
  final int limit;

  const _CategoryBudgetRow({
    required this.category,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit > 0;
    final progress =
        hasLimit ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final barColor = !hasLimit
        ? AppColors.textDisabled
        : progress >= 1.0
            ? AppColors.expense
            : progress >= 0.8
                ? AppColors.warning
                : AppColors.income;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                            category.color.replaceAll('#', '0xFF')))
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: Color(int.parse(
                        category.color.replaceAll('#', '0xFF'))),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(category.name, style: AppTextStyles.bodyMedium),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(spent.toBRL,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: barColor)),
                    if (hasLimit)
                      Text('de ${limit.toBRL}',
                          style: AppTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
            if (hasLimit) ...[
              const SizedBox(height: AppSizes.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: AppColors.divider,
                  color: barColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
