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
import '../../../../router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transactions_bloc.dart';
import '../widgets/month_navigation_bar.dart';
import '../widgets/transaction_list_item.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadTransactions();
  }

  void _loadTransactions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TransactionsBloc>().add(TransactionsLoadRequested(
            userId: authState.user.uid,
            year: _currentMonth.year,
            month: _currentMonth.month,
          ));
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadTransactions();
  }

  void _nextMonth() {
    if (_currentMonth.isBefore(DateTime(DateTime.now().year, DateTime.now().month))) {
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      });
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          MonthNavigationBar(
            currentMonth: _currentMonth,
            onPrevious: _previousMonth,
            onNext: _nextMonth,
            canGoNext: _currentMonth.isBefore(
              DateTime(DateTime.now().year, DateTime.now().month),
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state is TransactionsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is TransactionsError) {
                  return Center(
                    child: Text(state.message,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.error)),
                  );
                }

                if (state is TransactionsLoaded) {
                  if (state.transactions.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: AppStrings.noTransactions,
                      subtitle: AppStrings.noTransactionsSubtitle,
                    );
                  }

                  return Column(
                    children: [
                      _buildSummaryRow(state),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async => _loadTransactions(),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.sm),
                            itemCount: state.transactions.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: AppColors.divider, height: 1),
                            itemBuilder: (context, index) {
                              final transaction = state.transactions[index];
                              return TransactionListItem(
                                transaction: transaction,
                                onTap: () => context.push(
                                  AppRoutes.transactionDetail,
                                  extra: transaction,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(TransactionsLoaded state) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: 'Receitas',
              amount: state.totalIncome.toBRL,
              color: AppColors.income,
            ),
          ),
          Container(width: 1, height: 32, color: AppColors.divider),
          Expanded(
            child: _SummaryItem(
              label: 'Despesas',
              amount: state.totalExpenses.toBRL,
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.titleLarge.copyWith(color: color),
        ),
      ],
    );
  }
}
