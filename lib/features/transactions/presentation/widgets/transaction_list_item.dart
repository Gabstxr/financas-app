import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transaction.isTransfer) return _buildTransferTile();

    final color = transaction.isIncome ? AppColors.income : AppColors.expense;
    final sign = transaction.isIncome ? '+' : '-';
    final categoryColor = transaction.categoryColor != null
        ? Color(int.parse(transaction.categoryColor!.replaceAll('#', '0xFF')))
        : AppColors.primary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(Icons.circle, color: categoryColor, size: 16),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (transaction.categoryName != null) ...[
                        Text(
                          transaction.categoryName!,
                          style: AppTextStyles.labelSmall,
                        ),
                        const SizedBox(width: AppSizes.xs),
                        const Text('·', style: AppTextStyles.bodySmall),
                        const SizedBox(width: AppSizes.xs),
                      ],
                      Text(
                        transaction.date.toRelative,
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '$sign${transaction.amount.toBRL}',
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferTile() {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: const Icon(Icons.swap_horiz_rounded,
                  color: AppColors.primaryLight, size: 22),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : 'Transferência',
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (transaction.accountName != null)
                        Text(transaction.accountName!,
                            style: AppTextStyles.labelSmall),
                      const Text(' → ', style: AppTextStyles.labelSmall),
                      Text(
                        transaction.date.toRelative,
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              transaction.amount.toBRL,
              style: AppTextStyles.amountSmall
                  .copyWith(color: AppColors.primaryLight),
            ),
          ],
        ),
      ),
    );
  }
}
