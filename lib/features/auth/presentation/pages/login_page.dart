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
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignInWithEmailRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
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
                    const SizedBox(height: AppSizes.xxl),
                    _buildHeader(),
                    const SizedBox(height: AppSizes.xxl),
                    AppTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: AppStrings.password,
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: Validators.password,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(context),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          AppStrings.forgotPassword,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppButton(
                      label: AppStrings.login,
                      onPressed: () => _submit(context),
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: AppSizes.md),
                    _buildDivider(),
                    const SizedBox(height: AppSizes.md),
                    _buildGoogleButton(context, isLoading),
                    const SizedBox(height: AppSizes.xl),
                    _buildRegisterLink(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.account_balance_wallet_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(height: AppSizes.lg),
        Text('Bem-vindo de volta', style: AppTextStyles.displayMedium),
        const SizedBox(height: AppSizes.sm),
        Text(
          'Entre para continuar controlando suas finanças',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'ou',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context, bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading
          ? null
          : () => context.read<AuthBloc>().add(AuthSignInWithGoogleRequested()),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.g_mobiledata_rounded, size: 24, color: AppColors.textPrimary),
          const SizedBox(width: AppSizes.sm),
          Text(
            AppStrings.loginWithGoogle,
            style: AppTextStyles.labelLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.noAccount,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.register),
          child: Text(
            AppStrings.signUp,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
