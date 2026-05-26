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
  AccountEntity? _selectedToAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    final initIndex = widget.transaction?.isIncome == true
        ? 0
        : widget.transaction?.isTransfer == true
            ? 2
            : 1;
    _tabController = TabController(length: 3, vsync: this, initialIndex: initIndex);
    if (_isEditing) _prefillForm();
  }

  void _prefillForm() {
    final t = widget.transaction!;
    _descriptionController.text = t.description == 'Transferência' ? '' : t.description;
    _amountController.text = t.amount.toReaisFormatted;
    _notesController.text = t.notes ?? '';
    _selectedDate = t.date;

    // Pré-seleciona contas ao editar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountsState = context.read<AccountsBloc>().state;
      if (accountsState is AccountsLoaded) {
        setState(() {
          _selectedAccount = accountsState.accounts
              .where((a) => a.id == t.accountId)
              .firstOrNull;
          if (t.isTransfer && t.toAccountId != null) {
            _selectedToAccount = accountsState.accounts
                .where((a) => a.id == t.toAccountId)
                .firstOrNull;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  FullTransactionType get _currentType {
    switch (_tabController.index) {
      case 0:
        return FullTransactionType.income;
      case 2:
        return FullTransactionType.transfer;
      default:
        return FullTransactionType.expense;
    }
  }

  bool get _isTransfer => _currentType == FullTransactionType.transfer;

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() == false) return;

    if (!_isTransfer && _selectedCategory == null) {
      _showError(context, 'Selecione uma categoria.');
      return;
    }
    if (_selectedAccount == null) {
      _showError(context, _isTransfer ? 'Selecione a conta de origem.' : 'Selecione uma conta.');
      return;
    }
    if (_isTransfer && _selectedToAccount == null) {
      _showError(context, 'Selecione a conta de destino.');
      return;
    }
    if (_isTransfer && _selectedAccount!.id == _selectedToAccount!.id) {
      _showError(context, 'Conta de origem e destino não podem ser iguais.');
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
      description: _descriptionController.text.trim().isEmpty && _isTransfer
          ? 'Transferência'
          : _descriptionController.text.trim(),
      categoryId: _isTransfer ? 'transfer' : _selectedCategory!.id,
      accountId: _selectedAccount!.id,
      toAccountId: _isTransfer ? _selectedToAccount!.id : null,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
      categoryName: _isTransfer ? null : _selectedCategory!.name,
      categoryIcon: _isTransfer ? null : _selectedCategory!.icon,
      categoryColor: _isTransfer ? null : _selectedCategory!.color,
      accountName: _selectedAccount!.name,
      toAccountName: _isTransfer ? _selectedToAccount!.name : null,
    );

    if (_isEditing) {
      context.read<TransactionsBloc>().add(TransactionsUpdateRequested(
            oldTransaction: widget.transaction!,
            transaction: transaction,
          ));
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
                    if (!_isTransfer) ...[
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
                      _buildAccountSelector(context, label: AppStrings.account),
                    ] else ...[
                      AppTextField(
                        label: 'Descrição (opcional)',
                        controller: _descriptionController,
                        prefixIcon: Icons.description_outlined,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSizes.md),
                      _buildAccountSelector(context, label: 'Conta de origem'),
                      const SizedBox(height: AppSizes.md),
                      _buildToAccountSelector(context),
                    ],
                    const SizedBox(height: AppSizes.md),
                    _buildDateSelector(context),
                    const SizedBox(height: AppSizes.md),
                    if (!_isTransfer)
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
          Tab(text: 'Transferência'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildAmountField() {
    final color = _isTransfer
        ? AppColors.primaryLight
        : _currentType == FullTransactionType.income
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
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountSelector(BuildContext context, {required String label}) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final accounts =
            state is AccountsLoaded ? state.accounts : <AccountEntity>[];
        return _accountPickerTile(
          label: label,
          selected: _selectedAccount,
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => _showAccountPicker(
            context,
            accounts,
            onSelected: (a) => setState(() => _selectedAccount = a),
            excludeId: _selectedToAccount?.id,
          ),
        );
      },
    );
  }

  Widget _buildToAccountSelector(BuildContext context) {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final accounts =
            state is AccountsLoaded ? state.accounts : <AccountEntity>[];
        return _accountPickerTile(
          label: 'Conta de destino',
          selected: _selectedToAccount,
          icon: Icons.south_west_rounded,
          onTap: () => _showAccountPicker(
            context,
            accounts,
            onSelected: (a) => setState(() => _selectedToAccount = a),
            excludeId: _selectedAccount?.id,
          ),
        );
      },
    );
  }

  Widget _accountPickerTile({
    required String label,
    required AccountEntity? selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    selected?.name ?? 'Selecionar conta',
                    style: selected != null
                        ? AppTextStyles.bodyLarge
                        : AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
            if (selected != null) ...[
              Text(selected.balance.toBRL,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: AppSizes.xs),
            ],
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
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
            const Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                _selectedDate.toLocal().toString().split(' ')[0],
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(
      BuildContext context, List<CategoryEntity> categories) {
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

  void _showAccountPicker(
    BuildContext context,
    List<AccountEntity> accounts, {
    required ValueChanged<AccountEntity> onSelected,
    String? excludeId,
  }) {
    final filtered =
        accounts.where((a) => a.id != excludeId).toList();
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
            ...filtered.map((acc) => ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(acc.name),
                  subtitle: Text(acc.balance.toBRL),
                  onTap: () {
                    onSelected(acc);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
