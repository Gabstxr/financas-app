import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../injection/injection_container.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/widgets/transaction_list_item.dart';
import '../bloc/dashboard_cubit.dart';
import '../widgets/balance_card.dart';
import '../widgets/month_selector.dart';
import '../widgets/summary_cards_row.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final authState = context.read<AuthBloc>().state;
        final cubit = sl<DashboardCubit>();
        if (authState is AuthAuthenticated) {
          cubit.load(authState.user.uid);
        }
        return cubit;
      },
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
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
              if (authState is AuthAuthenticated) {
                final month = state is DashboardLoaded ? state.currentMonth : null;
                context.read<DashboardCubit>().load(authState.user.uid, month: month);
              }
            },
            child: switch (state) {
              DashboardLoading() => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              DashboardError(:final message) => Center(
                  child: Text(message, style: AppTextStyles.bodyMedium),
                ),
              DashboardLoaded() => _buildContent(context, state as DashboardLoaded),
              _ => const SizedBox(),
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
              context.read<DashboardCubit>().changeMonth(authState.user.uid, prev);
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
                    .read<DashboardCubit>()
                    .changeMonth(authState.user.uid, next);
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
