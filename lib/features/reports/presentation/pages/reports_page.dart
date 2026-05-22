import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/presentation/widgets/month_navigation_bar.dart';
import '../bloc/reports_cubit.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final authState = context.read<AuthBloc>().state;
        final cubit = sl<ReportsCubit>();
        if (authState is AuthAuthenticated) {
          cubit.load(authState.user.uid);
        }
        return cubit;
      },
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Relatórios')),
          body: switch (state) {
            ReportsLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ReportsError(:final message) => Center(child: Text(message)),
            ReportsLoaded() => _buildContent(context, state),
            _ => const SizedBox(),
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ReportsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthNavigationBar(
            currentMonth: state.currentMonth,
            onPrevious: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                final prev = DateTime(
                    state.currentMonth.year, state.currentMonth.month - 1);
                context.read<ReportsCubit>().load(authState.user.uid, month: prev);
              }
            },
            onNext: () {
              final now = DateTime.now();
              if (state.currentMonth.isBefore(DateTime(now.year, now.month))) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  final next = DateTime(
                      state.currentMonth.year, state.currentMonth.month + 1);
                  context
                      .read<ReportsCubit>()
                      .load(authState.user.uid, month: next);
                }
              }
            },
          ),
          const SizedBox(height: AppSizes.lg),
          _buildIncomeExpenseSummary(state),
          const SizedBox(height: AppSizes.lg),
          if (state.expensesByCategory.isNotEmpty) ...[
            Text('Despesas por Categoria', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSizes.md),
            _buildPieChart(state),
            const SizedBox(height: AppSizes.lg),
            _buildCategoryList(state),
          ] else
            EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'Sem dados neste mês',
              subtitle: 'Adicione transações para ver os relatórios',
            ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseSummary(ReportsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Receitas',
                  amount: state.totalIncome.toBRL,
                  color: AppColors.income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.divider),
              Expanded(
                child: _SummaryItem(
                  label: 'Despesas',
                  amount: state.totalExpenses.toBRL,
                  color: AppColors.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saldo do mês', style: AppTextStyles.labelMedium),
              Text(
                (state.totalIncome - state.totalExpenses).toBRL,
                style: AppTextStyles.amountSmall.copyWith(
                  color: state.totalIncome >= state.totalExpenses
                      ? AppColors.income
                      : AppColors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ReportsLoaded state) {
    final entries = state.expensesByCategory.entries.toList();
    final total = state.totalExpenses;
    final colors = AppColors.categoryColors;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: entries.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            final percent = total > 0 ? (e.value / total * 100) : 0;
            return PieChartSectionData(
              color: colors[i % colors.length],
              value: e.value.toDouble(),
              title: '${percent.toStringAsFixed(0)}%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            );
          }).toList(),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryList(ReportsLoaded state) {
    final entries = state.expensesByCategory.entries.toList();
    final total = state.totalExpenses;
    final colors = AppColors.categoryColors;

    return Column(
      children: entries.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final percent = total > 0 ? e.value / total : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: AppTextStyles.bodyMedium),
                        Text(e.value.toBRL,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.expense)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent.toDouble(),
                        backgroundColor: AppColors.divider,
                        color: colors[i % colors.length],
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 2),
        Text(amount, style: AppTextStyles.titleMedium.copyWith(color: color)),
      ],
    );
  }
}
