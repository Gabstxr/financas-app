import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../injection/injection_container.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/account_entity.dart';
import '../bloc/accounts_bloc.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final authState = context.read<AuthBloc>().state;
        final bloc = sl<AccountsBloc>();
        if (authState is AuthAuthenticated) {
          bloc.add(AccountsLoadRequested(authState.user.uid));
        }
        return bloc;
      },
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.accounts),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(AppRoutes.addAccount),
          ),
        ],
      ),
      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is AccountsLoaded) {
            if (state.accounts.isEmpty) {
              return EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: AppStrings.noAccounts,
                action: TextButton.icon(
                  onPressed: () => context.push(AppRoutes.addAccount),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar conta'),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                _buildTotalCard(state.totalBalance),
                const SizedBox(height: AppSizes.md),
                ...state.accounts.map((account) =>
                    _AccountCard(account: account)),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTotalCard(int total) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patrimônio Total',
              style: AppTextStyles.labelMedium
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: AppSizes.sm),
          Text(total.toBRL,
              style:
                  AppTextStyles.amountMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountEntity account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.tryParse(account.color.replaceAll('#', '0xFF')) ??
          0xFF7C3AED,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(Icons.account_balance_wallet_rounded,
                color: color, size: 24),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: AppTextStyles.titleMedium),
                Text(account.type.label, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            account.balance.toBRL,
            style: AppTextStyles.amountSmall.copyWith(
              color: account.balance >= 0
                  ? AppColors.textPrimary
                  : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
