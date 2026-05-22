import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../core/theme/app_text_styles.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
    this.canGoNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.textPrimary,
            onPressed: onPrevious,
            iconSize: 28,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            currentMonth.toMonthYear,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(width: AppSizes.sm),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext ? AppColors.textPrimary : AppColors.textDisabled,
            ),
            onPressed: canGoNext ? onNext : null,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
