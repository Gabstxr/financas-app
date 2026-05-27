import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../injection/injection_container.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';
import '../bloc/dashboard_cubit.dart';
import '../widgets/balance_card.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_cards_row.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = sl<DashboardCubit>();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated &&
        _dashboardCubit.state is! DashboardLoaded) {
      _dashboardCubit.load(authState.user.uid);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardState>(
      stream: _dashboardCubit.stream,
      initialData: _dashboardCubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _dashboardCubit.state;
        final authState = context.read<AuthBloc>().state;
        final userName = authState is AuthAuthenticated
            ? authState.user.displayName.split(' ').first
            : 'Usuário';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, $userName 👋',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.textSecondary)),
                Text('Suas finanças', style: AppTextStyles.headlineSmall),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                onPressed: () => context.push(AppRoutes.accounts),
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              final s = context.read<AuthBloc>().state;
              if (s is AuthAuthenticated) {
                final month =
                    state is DashboardLoaded ? state.currentMonth : null;
                _dashboardCubit.load(s.user.uid, month: month);
              }
            },
            child: switch (state) {
              DashboardLoading() => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              DashboardError(:final message) => Center(
                  child: Text(message, style: AppTextStyles.bodyMedium),
                ),
              DashboardLoaded() => _buildContent(context, state),
              _ => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      children: [
        MonthSelector(
          currentMonth: state.currentMonth,
          onPrevious: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              final prev = DateTime(
                  state.currentMonth.year, state.currentMonth.month - 1);
              _dashboardCubit.changeMonth(authState.user.uid, prev);
            }
          },
          onNext: () {
            final now = DateTime.now();
            if (state.currentMonth.isBefore(DateTime(now.year, now.month))) {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                final next = DateTime(
                    state.currentMonth.year, state.currentMonth.month + 1);
                _dashboardCubit.changeMonth(authState.user.uid, next);
              }
            }
          },
          canGoNext: state.currentMonth
              .isBefore(DateTime(DateTime.now().year, DateTime.now().month)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: BalanceCard(totalBalance: state.totalBalance),
        ),
        const SizedBox(height: AppSizes.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: SummaryCardsRow(
            income: state.monthlyIncome,
            expenses: state.monthlyExpenses,
          ),
        ),
        if (state.planning != null) ...[
          const SizedBox(height: AppSizes.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: _HealthCard(state: state),
          ),
        ],
        if (state.pendingBills.isNotEmpty) ...[
          const SizedBox(height: AppSizes.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: _UpcomingBillsCard(state: state),
          ),
        ],
        const SizedBox(height: AppSizes.lg),
        if (state.recentTransactions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.recentTransactions,
                    style: AppTextStyles.headlineSmall),
                TextButton(
                  onPressed: () => context.go(AppRoutes.transactions),
                  child: const Text(AppStrings.seeAll),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                for (int i = 0; i < state.recentTransactions.length; i++) ...[
                  if (i > 0)
                    const Divider(color: AppColors.divider, height: 1),
                  TransactionListItem(
                    transaction: state.recentTransactions[i],
                    onTap: () => context.push(
                      AppRoutes.transactionDetail,
                      extra: state.recentTransactions[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: AppStrings.noTransactions,
            subtitle: AppStrings.noTransactionsSubtitle,
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _UpcomingBillsCard extends StatelessWidget {
  final DashboardLoaded state;
  const _UpcomingBillsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final overdue = state.pendingBills.where((b) => b.isOverdue).toList();
    final dueSoon = state.pendingBills.where((b) => b.isDueSoon).toList();
    final headerColor = overdue.isNotEmpty ? AppColors.expense : AppColors.warning;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.bills),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: headerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: headerColor, size: 18),
                const SizedBox(width: AppSizes.xs),
                Text('Contas a pagar', style: AppTextStyles.labelMedium),
                const Spacer(),
                Text(
                  'Ver todas',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primaryLight),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.primaryLight),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            ...state.pendingBills.take(3).map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.xs),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: b.isOverdue ? AppColors.expense : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(b.name, style: AppTextStyles.bodySmall),
                      ),
                      Text(
                        DateFormat('dd/MM', 'pt_BR').format(b.dueDate),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: b.isOverdue ? AppColors.expense : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        b.amount > 0 ? b.amount.toBRL : '—',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                )),
            if (state.pendingBills.length > 3) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                '+${state.pendingBills.length - 3} outras contas',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                '${overdue.length} vencida${overdue.length > 1 ? 's' : ''}  •  '
                '${dueSoon.length} vencem em breve',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.expense),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final DashboardLoaded state;
  const _HealthCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final plan = state.planning!;
    final spent = state.monthlyExpenses;
    final budget = plan.spendingBudget;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = (budget - spent).clamp(0, double.maxFinite).toInt();
    final isOver = spent > budget;
    final barColor = isOver
        ? AppColors.expense
        : progress >= 0.8
            ? AppColors.warning
            : AppColors.income;

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
              Icon(Icons.favorite_outline_rounded,
                  color: barColor, size: 18),
              const SizedBox(width: AppSizes.xs),
              Text('Saúde financeira', style: AppTextStyles.labelMedium),
              const Spacer(),
              TextButton(
                onPressed: () => context.go(AppRoutes.planning),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppColors.primaryLight,
                ),
                child: const Text('Ver plano'),
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
              color: barColor,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOver
                    ? 'Orçamento estourado em ${(spent - budget).toBRL}'
                    : '${remaining.toBRL} restante',
                style: AppTextStyles.labelSmall.copyWith(color: barColor),
              ),
              Text(
                '${spent.toBRL} / ${budget.toBRL}',
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
