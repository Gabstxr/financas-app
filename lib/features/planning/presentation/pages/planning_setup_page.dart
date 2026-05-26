import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/planning_engine.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../domain/entities/planning_entity.dart';
import '../cubit/planning_cubit.dart';

class PlanningSetupPage extends StatefulWidget {
  final PlanningEntity? existing;
  final List<CategoryEntity> categories;
  final PlanningCubit cubit;
  final String userId;
  final DateTime month;
  final int defaultSalary;

  const PlanningSetupPage({
    super.key,
    required this.existing,
    required this.categories,
    required this.cubit,
    required this.userId,
    required this.month,
    this.defaultSalary = 0,
  });

  @override
  State<PlanningSetupPage> createState() => _PlanningSetupPageState();
}

class _PlanningSetupPageState extends State<PlanningSetupPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _salaryCtrl;
  late final TextEditingController _fixedCtrl;
  late double _savingsPercent;
  late Map<String, TextEditingController> _limitControllers;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _salaryCtrl = TextEditingController(
      text: p != null && p.salary > 0
          ? p.salary.toReaisFormatted
          : (widget.defaultSalary > 0 ? widget.defaultSalary.toReaisFormatted : ''),
    );
    _fixedCtrl = TextEditingController(
      text: p != null && p.fixedExpenses > 0 ? p.fixedExpenses.toReaisFormatted : '',
    );
    _savingsPercent = p?.savingsGoalPercent.toDouble() ?? 20;
    _limitControllers = {
      for (final cat in widget.categories)
        cat.id: TextEditingController(
          text: (p?.categoryLimits[cat.id] ?? 0) > 0
              ? (p!.categoryLimits[cat.id]!).toReaisFormatted
              : '',
        ),
    };
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _fixedCtrl.dispose();
    for (final c in _limitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _salary => _salaryCtrl.text.parseToCents;
  int get _fixed => _fixedCtrl.text.parseToCents;
  int get _spendingBudget {
    final disposable = _salary - _fixed;
    if (disposable <= 0) return 0;
    return (disposable * (1 - _savingsPercent / 100)).round();
  }

  void _applySuggestions() {
    final budget = _spendingBudget;
    final suggestions = PlanningEngine.suggestLimits(widget.categories, budget);
    setState(() {
      for (final cat in widget.categories) {
        final suggested = suggestions[cat.id] ?? 0;
        _limitControllers[cat.id]?.text =
            suggested > 0 ? suggested.toReaisFormatted : '';
      }
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final now = DateTime.now();
    final limits = <String, int>{
      for (final cat in widget.categories)
        cat.id: _limitControllers[cat.id]?.text.parseToCents ?? 0,
    };

    final planning = PlanningEntity(
      id: PlanningCubit.monthId(widget.month),
      userId: widget.userId,
      salary: _salary,
      fixedExpenses: _fixed,
      savingsGoalPercent: _savingsPercent.round(),
      categoryLimits: limits,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    widget.cubit.save(widget.userId, planning);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        DateFormat('MMMM yyyy', 'pt_BR').format(widget.month);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Plano de ${_capitalize(monthLabel)}'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            _buildSectionTitle('Renda e economia'),
            const SizedBox(height: AppSizes.sm),
            _buildCurrencyField(
              controller: _salaryCtrl,
              label: 'Salário mensal',
              icon: Icons.work_outline_rounded,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSizes.sm),
            _buildCurrencyField(
              controller: _fixedCtrl,
              label: 'Contas fixas (aluguel, luz, etc.)',
              icon: Icons.receipt_long_outlined,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSizes.md),
            _buildSavingsSlider(),
            const SizedBox(height: AppSizes.lg),
            _buildBudgetSummary(),
            const SizedBox(height: AppSizes.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Limites por categoria'),
                TextButton.icon(
                  onPressed: _applySuggestions,
                  icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                  label: const Text('Sugerir Kakeibo'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryLight,
                    textStyle: AppTextStyles.labelMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Opcional — defina quanto quer gastar por categoria',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSizes.sm),
            ...widget.categories.map((cat) => _buildCategoryLimitRow(cat)),
            const SizedBox(height: AppSizes.xl),
            AppButton(
              label: 'Salvar plano',
              onPressed: _save,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) =>
      Text(text, style: AppTextStyles.titleLarge);

  Widget _buildCurrencyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyInputFormatter()],
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildSavingsSlider() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Meta de economia', style: AppTextStyles.bodyMedium),
              Text(
                '${_savingsPercent.round()}%',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.income),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.income,
              thumbColor: AppColors.income,
              inactiveTrackColor: AppColors.divider,
              overlayColor: AppColors.income.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _savingsPercent,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (v) => setState(() => _savingsPercent = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: AppTextStyles.labelSmall),
              Text('50%', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummary() {
    final disposable = _salary - _fixed;
    final savings = (disposable * _savingsPercent / 100).round();
    final spending = disposable - savings;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _summaryRow('Renda disponível', disposable > 0 ? disposable : 0),
          const Divider(color: AppColors.divider, height: AppSizes.lg),
          _summaryRow('Para guardar', savings > 0 ? savings : 0,
              color: AppColors.income),
          const SizedBox(height: AppSizes.xs),
          _summaryRow('Para gastar', spending > 0 ? spending : 0,
              color: AppColors.expense),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int amount, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          amount.toBRL,
          style: AppTextStyles.amountSmall.copyWith(
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryLimitRow(CategoryEntity cat) {
    final pillar = PlanningEngine.pillarForCategory(cat.name);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: pillar.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            flex: 2,
            child: Text(cat.name, style: AppTextStyles.bodyMedium),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _limitControllers[cat.id],
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'R\$ 0,00',
                hintStyle: AppTextStyles.bodySmall,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: AppSizes.xs),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusSm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusSm),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppSizes.radiusSm),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
