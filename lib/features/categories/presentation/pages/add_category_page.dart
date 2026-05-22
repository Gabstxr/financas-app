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
import '../../domain/entities/category_entity.dart';
import '../bloc/categories_bloc.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _selectedType = TransactionType.expense;
  String _selectedColor = '#7C3AED';

  final List<String> _colors = [
    '#7C3AED', '#10B981', '#EF4444', '#3B82F6',
    '#F59E0B', '#8B5CF6', '#06B6D4', '#EC4899',
    '#84CC16', '#FF6B35', '#14B8A6', '#F43F5E',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final category = CategoryEntity(
      id: '',
      userId: authState.user.uid,
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: 'category',
      color: _selectedColor,
      createdAt: DateTime.now(),
    );

    context.read<CategoriesBloc>().add(CategoriesAddRequested(category));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.addCategory)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: AppStrings.categoryName,
                controller: _nameController,
                prefixIcon: Icons.category_outlined,
                validator: (v) => Validators.required(v, 'Nome'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSizes.md),
              Text('Tipo', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: TransactionType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: Container(
                        margin: type == TransactionType.expense
                            ? const EdgeInsets.only(right: AppSizes.sm / 2)
                            : const EdgeInsets.only(left: AppSizes.sm / 2),
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (type == TransactionType.expense
                                  ? AppColors.expense.withOpacity(0.15)
                                  : AppColors.income.withOpacity(0.15))
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(
                            color: isSelected
                                ? (type == TransactionType.expense
                                    ? AppColors.expense
                                    : AppColors.income)
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type.label,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected
                                  ? (type == TransactionType.expense
                                      ? AppColors.expense
                                      : AppColors.income)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.md),
              Text('Cor', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSizes.sm),
              Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: _colors.map((colorHex) {
                  final color =
                      Color(int.parse(colorHex.replaceAll('#', '0xFF')));
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
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
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
}
