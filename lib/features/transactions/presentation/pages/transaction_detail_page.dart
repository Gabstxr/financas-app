import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transactions_bloc.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionEntity transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = transaction.isTransfer
        ? AppColors.primaryLight
        : transaction.isIncome
            ? AppColors.income
            : AppColors.expense;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.addTransaction, extra: transaction),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            _buildAmountCard(color),
            const SizedBox(height: AppSizes.md),
            _buildDetailsCard(),
            const SizedBox(height: AppSizes.lg),
            AppButton.danger(
              label: AppStrings.delete,
              icon: Icons.delete_outline_rounded,
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isTransfer
                  ? Icons.swap_horiz_rounded
                  : transaction.isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(transaction.description, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSizes.sm),
          Text(
            transaction.amount.toBRL,
            style: AppTextStyles.amountLarge.copyWith(color: color),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            transaction.date.toLongDate,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          if (!transaction.isTransfer) ...[
            _DetailRow(
              icon: Icons.category_outlined,
              label: AppStrings.category,
              value: transaction.categoryName ?? '-',
            ),
            const Divider(color: AppColors.divider, height: 1),
          ],
          _DetailRow(
            icon: Icons.account_balance_wallet_outlined,
            label: transaction.isTransfer ? 'Conta de origem' : AppStrings.account,
            value: transaction.accountName ?? '-',
          ),
          if (transaction.isTransfer) ...[
            const Divider(color: AppColors.divider, height: 1),
            _DetailRow(
              icon: Icons.south_west_rounded,
              label: 'Conta de destino',
              value: transaction.toAccountName ?? transaction.toAccountId ?? '-',
            ),
          ],
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 1),
            _DetailRow(
              icon: Icons.notes_rounded,
              label: 'Observações',
              value: transaction.notes!,
            ),
          ],
          const Divider(color: AppColors.divider, height: 1),
          _DetailRow(
            icon: Icons.access_time_rounded,
            label: 'Cadastrado em',
            value: transaction.createdAt.toLongDate,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteTransactionTitle),
        content: const Text(AppStrings.deleteTransactionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<TransactionsBloc>().add(
                      TransactionsDeleteRequested(transaction),
                    );
              }
              Navigator.pop(dialogContext);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.md),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
