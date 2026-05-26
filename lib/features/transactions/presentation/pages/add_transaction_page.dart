import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../accounts/domain/entities/account_entity.dart';
import '../../../accounts/presentation/bloc/accounts_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transactions_bloc.dart';

class AddTransactionPage extends StatefulWidget {
  final TransactionEntity? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.transaction?.isIncome == true ? 0 : 1,
    );
    if (_isEditing) _prefillForm();
  }

  void _prefillForm() {
    final t = widget.transaction!;
    _descriptionController.text = t.description;
    _amountController.text = t.amount.toReaisFormatted;
    _notesController.text = t.notes ?? '';
    _selectedDate = t.date;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  FullTransactionType get _currentType =>
      _tabController.index == 0 ? FullTransactionType.income : FullTransactionType.expense;

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() == false) return;
    if (_selectedCategory == null) {
      _showError(context, 'Selecione uma categoria.');
      return;
    }
    if (_selectedAccount == null) {
      _showError(context, 'Selecione uma conta.');
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final amount = _amountController.text.parseToCents;
    final now = DateTime.now();

    final transaction = TransactionEntity(
      id: widget.transaction?.id ?? '',
      userId: authState.user.uid,
      type: _currentType,
      amount: amount,
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategory!.id,
      accountId: _selectedAccount!.id,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
      categoryName: _selectedCategory!.name,
      categoryIcon: _selectedCategory!.icon,
      categoryColor: _selectedCategory!.color,
      accountName: _selectedAccount!.name,
    );

    if (_isEditing) {
      context.read<TransactionsBloc>().add(TransactionsUpdateRequested(transaction));
    } else {
      context.read<TransactionsBloc>().add(TransactionsAddRequested(transaction));
    }
    context.pop();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isEditing ? AppStrings.editTransaction : AppStrings.addTransaction),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            _buildTypeTab(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    children: [
                      _buildAmountField(),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: AppStrings.description,
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        validator: (v) => Validators.required(v, 'Descrição'),
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildCategorySelector(context),
                      const SizedBox(height: AppSizes.md),
                      _buildAccountSelector(context),
                      const SizedBox(height: AppSizes.md),
                      _buildDateSelector(context),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: 'Observações (opcional)',
                        controller: _notesController,
                        prefixIcon: Icons.notes_rounded,
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      AppButton(
                        label: _isEditing ? AppStrings.save : 'Adicionar',
                        onPressed: () => _submit(context),
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildTypeTab() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'Receita'),
          Tab(text: 'Despesa'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildAmountField() {
    final color = _currentType == FullTransactionType.income
        ? AppColors.income
        : AppColors.expense;
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTextStyles.amountLarge.copyWith(color: color),
        inputFormatters: [CurrencyInputFormatter()],
        validator: Validators.amount,
        decoration: InputDecoration(
          hintText: 'R\$ 0,00',
          hintStyle: AppTextStyles.amountLarge.copyWith(
            color: color.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final categories = state is CategoriesLoaded
            ? (_tabController.index == 0
                ? state.incomeCategories
                : state.expenseCategories)
            : <CategoryEntity>[];

        return InkWell(
          onTap: () => _showCategoryPicker(context, categories),
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
                const Icon(Icons.category_outlined, color: AppColors.textSecondary),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    _selectedCategory?.name ?? AppStrings.category,
                    style: _selectedCategory != null
                        ? AppTextStyles.bodyLarge
                        : AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textDisabled),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSelector(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final accounts =
            state is AccountsLoaded ? state.accounts : <AccountEntity>[];

        return InkWell(
          onTap: () => _showAccountPicker(context, accounts),
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
                    _selectedAccount?.name ?? AppStrings.account,
                    style: _selectedAccount != null
                        ? AppTextStyles.bodyLarge
                        : AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textDisabled),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context)
                  .colorScheme
                  .copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDate = picked);
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
            const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                _selectedDate.toLocal().toString().split(' ')[0],
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, List<CategoryEntity> categories) {
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
              child: Text('Selecionar categoria', style: AppTextStyles.headlineSmall),
            ),
            const Divider(color: AppColors.divider),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        int.parse(cat.color.replaceAll('#', '0xFF')),
                      ).withValues(alpha: 0.2),
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

  void _showAccountPicker(BuildContext context, List<AccountEntity> accounts) {
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
              child: Text('Selecionar conta', style: AppTextStyles.headlineSmall),
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
