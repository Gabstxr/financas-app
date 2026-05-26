import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../injection/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/bill_entity.dart';
import '../cubit/bills_cubit.dart';
import 'add_bill_page.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  late final BillsCubit _cubit;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _cubit = sl<BillsCubit>();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _userId = auth.user.uid;
      _cubit.load(_userId!);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _openAdd([BillEntity? existing]) {
    if (_userId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _cubit,
          child: AddBillPage(existing: existing, userId: _userId!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BillsState>(
      stream: _cubit.stream,
      initialData: _cubit.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? _cubit.state;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Contas a Pagar'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: _openAdd,
              ),
            ],
          ),
          body: switch (state) {
            BillsLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            BillsError(:final message) =>
              Center(child: Text(message, style: AppTextStyles.bodyMedium)),
            BillsLoaded() => _buildContent(state),
            _ => const SizedBox(),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: _openAdd,
            child: const Icon(Icons.add_rounded),
          ),
        );
      },
    );
  }

  Widget _buildContent(BillsLoaded state) {
    final hasAny = state.bills.isNotEmpty;
    if (!hasAny) {
      return EmptyState(
        icon: Icons.receipt_outlined,
        title: 'Nenhuma conta cadastrada',
        subtitle: 'Adicione contas recorrentes para acompanhar seus vencimentos.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        if (_userId != null) await _cubit.load(_userId!);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          if (state.overdue.isNotEmpty) ...[
            _sectionHeader('Vencidas', AppColors.expense, Icons.warning_rounded),
            const SizedBox(height: AppSizes.sm),
            ...state.overdue.map((b) => _BillCard(
                  bill: b,
                  onPay: () => _confirmPay(b),
                  onEdit: () => _openAdd(b),
                  onDelete: () => _confirmDelete(b),
                )),
            const SizedBox(height: AppSizes.md),
          ],
          if (state.dueSoon.isNotEmpty) ...[
            _sectionHeader('Vencem em breve', AppColors.warning, Icons.schedule_rounded),
            const SizedBox(height: AppSizes.sm),
            ...state.dueSoon.map((b) => _BillCard(
                  bill: b,
                  onPay: () => _confirmPay(b),
                  onEdit: () => _openAdd(b),
                  onDelete: () => _confirmDelete(b),
                )),
            const SizedBox(height: AppSizes.md),
          ],
          if (state.upcoming.isNotEmpty) ...[
            _sectionHeader('Próximas', AppColors.textSecondary, Icons.calendar_month_outlined),
            const SizedBox(height: AppSizes.sm),
            ...state.upcoming.map((b) => _BillCard(
                  bill: b,
                  onPay: () => _confirmPay(b),
                  onEdit: () => _openAdd(b),
                  onDelete: () => _confirmDelete(b),
                )),
            const SizedBox(height: AppSizes.md),
          ],
          if (state.paid.isNotEmpty) ...[
            _sectionHeader('Pagas', AppColors.income, Icons.check_circle_outline_rounded),
            const SizedBox(height: AppSizes.sm),
            ...state.paid.map((b) => _BillCard(
                  bill: b,
                  onPay: null,
                  onEdit: () => _openAdd(b),
                  onDelete: () => _confirmDelete(b),
                )),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSizes.xs),
        Text(label,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              letterSpacing: 0.5,
            )),
      ],
    );
  }

  void _confirmPay(BillEntity bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Marcar como paga?'),
        content: Text(
          'Isso criará uma transação de despesa de ${bill.amount.toBRL} e atualizará o saldo da conta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (_userId != null) _cubit.markPaid(bill, _userId!);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.income),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BillEntity bill) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Excluir conta?'),
        content: Text('A conta "${bill.name}" será removida.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_userId != null) _cubit.delete(_userId!, bill.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final BillEntity bill;
  final VoidCallback? onPay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BillCard({
    required this.bill,
    required this.onPay,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = bill.isPaid
        ? AppColors.income
        : bill.isOverdue
            ? AppColors.expense
            : bill.isDueSoon
                ? AppColors.warning
                : AppColors.textSecondary;

    final catColor = bill.categoryColor != null
        ? Color(int.parse(bill.categoryColor!.replaceAll('#', '0xFF')))
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: bill.isOverdue && !bill.isPaid
                ? AppColors.expense.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: AppSizes.xs),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: bill.isPaid
                ? const Icon(Icons.check_rounded, color: AppColors.income, size: 22)
                : Icon(Icons.receipt_outlined, color: catColor, size: 20),
          ),
          title: Text(
            bill.name,
            style: AppTextStyles.titleMedium.copyWith(
              decoration: bill.isPaid ? TextDecoration.lineThrough : null,
              color: bill.isPaid ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    bill.isPaid && bill.paidAt != null
                        ? 'Pago em ${DateFormat('dd/MM', 'pt_BR').format(bill.paidAt!)}'
                        : 'Vence ${DateFormat('dd/MM', 'pt_BR').format(bill.dueDate)}',
                    style: AppTextStyles.labelSmall.copyWith(color: statusColor),
                  ),
                  if (bill.isRecurring) ...[
                    const SizedBox(width: AppSizes.xs),
                    const Text('·', style: AppTextStyles.labelSmall),
                    const SizedBox(width: AppSizes.xs),
                    const Icon(Icons.repeat_rounded, size: 12, color: AppColors.textSecondary),
                  ],
                ],
              ),
              if (bill.accountName != null)
                Text(bill.accountName!, style: AppTextStyles.labelSmall),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bill.amount > 0 ? bill.amount.toBRL : 'A definir',
                    style: AppTextStyles.amountSmall.copyWith(
                      color: bill.isPaid ? AppColors.income : AppColors.expense,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSizes.sm),
              PopupMenuButton<String>(
                color: AppColors.card,
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.textSecondary, size: 20),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                  if (v == 'pay' && onPay != null) onPay!();
                },
                itemBuilder: (_) => [
                  if (!bill.isPaid)
                    const PopupMenuItem(
                        value: 'pay',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Marcar como paga'),
                        ])),
                  const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Excluir'),
                      ])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
