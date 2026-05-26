import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/injection_container.dart';
import '../../../../router/app_router.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          if (user != null) _buildProfileCard(user.displayName, user.email),
          const SizedBox(height: AppSizes.lg),
          _buildSection('Financeiro', [
            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Contas',
              onTap: () => context.push(AppRoutes.accounts),
            ),
            _SettingsTile(
              icon: Icons.category_outlined,
              title: 'Categorias',
              onTap: () => context.push(AppRoutes.categories),
            ),
            _SettingsTile(
              icon: Icons.calculate_outlined,
              title: 'Recalcular saldos',
              subtitle: 'Corrige saldos baseado em todas as transações',
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.card,
                    title: const Text('Recalcular saldos?'),
                    content: const Text(
                      'Isso recalcula o saldo de todas as contas com base em todas as transações registradas.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary),
                        child: const Text('Recalcular'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    sl<AccountsBloc>().add(
                      AccountsRecalculateRequested(authState.user.uid),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saldos recalculados!')),
                    );
                  }
                }
              },
            ),
          ]),
          const SizedBox(height: AppSizes.md),
          _buildSection('Geral', [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Sobre o app',
              subtitle: 'Versão 1.0.0',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSizes.lg),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.primaryLight),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleLarge),
                const SizedBox(height: 2),
                Text(email,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.sm, bottom: AppSizes.sm),
          child: Text(title.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(color: AppColors.divider, height: 1),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.error),
        foregroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: const Text(AppStrings.logout),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySmall)
          : null,
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
