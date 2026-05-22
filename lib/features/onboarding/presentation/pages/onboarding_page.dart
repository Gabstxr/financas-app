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
import '../../../../injection/injection_container.dart';
import '../../../../router/app_router.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/domain/usecases/add_account.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../categories/data/datasources/categories_remote_datasource.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType _selectedType = AccountType.checking;
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.uid;
    final balance = _balanceController.text.isNotEmpty
        ? int.tryParse(
                _balanceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0
        : 0;

    // Cria conta inicial
    final account = AccountEntity(
      id: '',
      userId: userId,
      name: _accountNameController.text.trim(),
      type: _selectedType,
      balance: balance,
      initialBalance: balance,
      color: '#7C3AED',
      icon: 'account_balance_wallet',
      createdAt: DateTime.now(),
    );

    await sl<AddAccount>().call(account);

    // Seed categorias padrão
    await sl<CategoriesRemoteDataSource>().seedDefaultCategories(userId);

    if (!context.mounted) return;
    context.read<AuthBloc>().add(AuthOnboardingCompleted(userId));
    setState(() => _isLoading = false);
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSizes.xl),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(AppStrings.welcomeTitle, style: AppTextStyles.displayMedium),
                const SizedBox(height: AppSizes.sm),
                Text(
                  AppStrings.welcomeSubtitle,
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xxl),
                Text('Nome da conta', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSizes.sm),
                AppTextField(
                  label: 'Ex: Nubank, Itaú, Carteira',
                  controller: _accountNameController,
                  prefixIcon: Icons.account_balance_wallet_outlined,
                  validator: (v) => Validators.required(v, 'Nome'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSizes.lg),
                Text('Tipo de conta', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSizes.sm),
                _buildAccountTypeSelector(),
                const SizedBox(height: AppSizes.lg),
                Text('Saldo atual (opcional)', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSizes.sm),
                AppTextField(
                  label: 'R\$ 0,00',
                  controller: _balanceController,
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSizes.xxl),
                AppButton(
                  label: AppStrings.getStarted,
                  onPressed: () => _finish(context),
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeSelector() {
    final types = [
      AccountType.checking,
      AccountType.savings,
      AccountType.cash,
    ];

    return Wrap(
      spacing: AppSizes.sm,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              type.label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
