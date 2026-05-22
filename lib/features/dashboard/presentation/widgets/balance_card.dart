import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';

class BalanceCard extends StatefulWidget {
  final int totalBalance;

  const BalanceCard({super.key, required this.totalBalance});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalBalance,
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isVisible = !_isVisible),
                child: Icon(
                  _isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            _isVisible ? widget.totalBalance.toBRL : '••••••',
            style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Colors.white54, size: 16),
              const SizedBox(width: 4),
              Text(
                'Saldo consolidado de todas as contas',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
