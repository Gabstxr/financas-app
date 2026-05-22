import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/date_extension.dart';
import '../../../../core/theme/app_text_styles.dart';

class MonthNavigationBar extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  const MonthNavigationBar({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
    this.canGoNext = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
            onPressed: onPrevious,
          ),
          Text(
            currentMonth.toMonthYear,
            style: AppTextStyles.titleMedium,
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext ? AppColors.textPrimary : AppColors.textDisabled,
            ),
            onPressed: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}
