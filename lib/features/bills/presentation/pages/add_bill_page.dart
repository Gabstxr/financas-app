import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../domain/entities/bill_entity.dart';
import '../cubit/bills_cubit.dart';

class AddBillPage extends StatefulWidget {
  final BillEntity? existing;
  final String userId;

  const AddBillPage({super.key, this.existing, required this.userId});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;
  bool _isRecurring = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.existing!;
      _nameCtrl.text = b.name;
      _amountCtrl.text = b.amount > 0 ? b.amount.toReaisFormatted : '';
      _notesCtrl.text = b.notes ?? '';
      _dueDate = b.dueDate;
      _isRecurring = b.isRecurring;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cats = context.read<CategoriesBloc>().state;
        if (cats is CategoriesLoaded) {
          setState(() {
            _selectedCategory = cats.expenseCategories
                .where((c) => c.id == b.categoryId)
                .firstOrNull;
          });
        }
        final accs = context.read<AccountsBloc>().state;
        if (accs is AccountsLoaded) {
          setState(() {
            _selectedAccount =
                accs.accounts.where((a) => a.id == b.accountId).firstOrNull;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      _showError('Selecione uma categoria.');
      return;
    }
    if (_selectedAccount == null) {
      _showError('Selecione uma conta.');
      return;
    }

    final now = DateTime.now();
    final bill = BillEntity(
      id: widget.existing?.id ?? '',
      userId: widget.userId,
      name: _nameCtrl.text.trim(),
      amount: _amountCtrl.text.trim().isEmpty ? 0 : _amountCtrl.text.parseToCents,
      dueDate: _dueDate,
      categoryId: _selectedCategory!.id,
      accountId: _selectedAccount!.id,
      isRecurring: _isRecurring,
      recurringDay: _isRecurring ? _dueDate.day : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
      categoryName: _selectedCategory!.name,
      categoryColor: _selectedCategory!.color,
      accountName: _selectedAccount!.name,
    );

    final cubit = context.read<BillsCubit>();
    if (_isEditing) {
      cubit.update(bill.copyWith(id: widget.existing!.id));
    } else {
      cubit.add(bill);
    }
    Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Conta' : 'Nova Conta'),
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
            _buildAmountField(),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyLarge,
              validator: (v) => Validators.required(v, 'Nome'),
              decoration: _inputDecoration('Nome da conta', Icons.receipt_outlined),
            ),
            const SizedBox(height: AppSizes.md),
            _buildDateSelector(),
            const SizedBox(height: AppSizes.md),
            _buildCategorySelector(),
            const SizedBox(height: AppSizes.md),
            _buildAccountSelector(),
            const SizedBox(height: AppSizes.md),
            _buildRecurringToggle(),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyLarge,
              decoration: _inputDecoration('Observações (opcional)', Icons.notes_rounded),
            ),
            const SizedBox(height: AppSizes.xl),
            AppButton(
              label: _isEditing ? 'Salvar' : 'Adicionar conta',
              onPressed: _save,
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountCtrl,
      keyboardType: TextInputType.number,
      inputFormatters: [CurrencyInputFormatter()],
      style: AppTextStyles.amountMedium,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'R\$ 0,00',
        hintStyle: AppTextStyles.amountMedium
            .copyWith(color: AppColors.textDisabled),
        filled: true,
        fillColor: AppColors.expense.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(color: AppColors.expense.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide(color: AppColors.expense.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: const BorderSide(color: AppColors.expense, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme:
                  Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _dueDate = picked);
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vencimento',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd/MM/yyyy', 'pt_BR').format(_dueDate),
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final cats = state is CategoriesLoaded
            ? state.expenseCategories
            : <CategoryEntity>[];
        return InkWell(
          onTap: () => _showCategoryPicker(cats),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.category_outlined,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    _selectedCategory?.name ?? 'Categoria',
                    style: _selectedCategory != null
                        ? AppTextStyles.bodyLarge
                        : AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textDisabled),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSelector() {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final accs =
            state is AccountsLoaded ? state.accounts : <AccountEntity>[];
        return InkWell(
          onTap: () => _showAccountPicker(accs),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    _selectedAccount?.name ?? 'Conta',
                    style: _selectedAccount != null
                        ? AppTextStyles.bodyLarge
                        : AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textDisabled),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecurringToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat_rounded, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recorrente todo mês', style: AppTextStyles.bodyLarge),
                Text(
                  'Cria automaticamente no próximo mês ao pagar',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _isRecurring,
            onChanged: (v) => setState(() => _isRecurring = v),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
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
    );
  }

  void _showCategoryPicker(List<CategoryEntity> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child:
                  Text('Selecionar categoria', style: AppTextStyles.headlineSmall),
            ),
            const Divider(color: AppColors.divider),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Color(int.parse(cat.color.replaceAll('#', '0xFF')))
                              .withValues(alpha: 0.2),
                      child: Icon(Icons.circle,
                          color: Color(
                              int.parse(cat.color.replaceAll('#', '0xFF'))),
                          size: 16),
                    ),
                    title: Text(cat.name),
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(context);
                    },
                    selected: _selectedCategory?.id == cat.id,
                    selectedTileColor: AppColors.primaryContainer,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(List<AccountEntity> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child:
                  Text('Selecionar conta', style: AppTextStyles.headlineSmall),
            ),
            const Divider(color: AppColors.divider),
            ...accounts.map((acc) => ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(acc.name),
                  subtitle: Text(acc.balance.toBRL),
                  onTap: () {
                    setState(() => _selectedAccount = acc);
                    Navigator.pop(context);
                  },
                  selected: _selectedAccount?.id == acc.id,
                  selectedTileColor: AppColors.primaryContainer,
                )),
          ],
        ),
      ),
    );
  }
}
