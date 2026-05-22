import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/account_entity.dart';
import '../bloc/accounts_bloc.dart';

class AddAccountPage extends StatefulWidget {
  final AccountEntity? account;

  const AddAccountPage({super.key, this.account});

  @override
  State<AddAccountPage> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType _selectedType = AccountType.checking;
  String _selectedColor = '#7C3AED';

  final List<String> _colors = [
    '#7C3AED', '#10B981', '#EF4444', '#3B82F6',
    '#F59E0B', '#8B5CF6', '#06B6D4', '#EC4899',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final balance = int.tryParse(
            _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;

    final account = AccountEntity(
      id: widget.account?.id ?? '',
      userId: authState.user.uid,
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: balance,
      initialBalance: balance,
      color: _selectedColor,
      icon: 'account_balance_wallet',
      createdAt: widget.account?.createdAt ?? DateTime.now(),
    );

    if (widget.account != null) {
      context.read<AccountsBloc>().add(AccountsUpdateRequested(account));
    } else {
      context.read<AccountsBloc>().add(AccountsAddRequested(account));
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.account != null
            ? AppStrings.editAccount
            : AppStrings.addAccount),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: AppStrings.accountName,
                controller: _nameController,
                prefixIcon: Icons.account_balance_wallet_outlined,
                validator: (v) => Validators.required(v, 'Nome'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSizes.md),
              Text(AppStrings.accountType, style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSizes.sm),
              _buildTypeSelector(),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: AppStrings.initialBalance,
                controller: _balanceController,
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSizes.md),
              Text('Cor da conta', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSizes.sm),
              _buildColorPicker(),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: AppStrings.save,
                onPressed: () => _submit(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: AccountType.values.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1),
            ),
            child: Text(
              type.label,
              style: AppTextStyles.labelLarge.copyWith(
                color:
                    isSelected ? AppColors.primaryLight : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: AppSizes.sm,
      children: _colors.map((colorHex) {
        final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
        final isSelected = _selectedColor == colorHex;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorHex),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
