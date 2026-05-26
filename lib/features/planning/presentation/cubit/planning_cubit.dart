import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/planning_engine.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/get_categories.dart';
import '../../../transactions/domain/usecases/get_transactions_by_month.dart';
import '../../domain/entities/planning_entity.dart';
import '../../domain/usecases/get_planning.dart';
import '../../domain/usecases/save_planning.dart';

part 'planning_state.dart';

class PlanningCubit extends Cubit<PlanningState> {
  final GetPlanning getPlanning;
  final SavePlanning savePlanning;
  final GetTransactionsByMonth getTransactionsByMonth;
  final GetCategories getCategories;

  PlanningCubit({
    required this.getPlanning,
    required this.savePlanning,
    required this.getTransactionsByMonth,
    required this.getCategories,
  }) : super(PlanningInitial());

  static String monthId(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  Future<void> load(String userId, {DateTime? month}) async {
    emit(PlanningLoading());

    final targetMonth = month ?? DateTime.now();
    final mid = monthId(targetMonth);

    final catResult = await getCategories(userId);
    List<CategoryEntity>? categories;
    catResult.fold(
      (f) => emit(PlanningError(f.message)),
      (cats) => categories = cats,
    );
    if (categories == null) return;

    final txResult =
        await getTransactionsByMonth(userId, targetMonth.year, targetMonth.month);
    final spentByCategory = <String, int>{};
    var totalIncome = 0;
    bool txError = false;
    txResult.fold(
      (f) {
        txError = true;
        emit(PlanningError(f.message));
      },
      (txs) {
        for (final tx in txs) {
          if (tx.isExpense) {
            spentByCategory[tx.categoryId] =
                (spentByCategory[tx.categoryId] ?? 0) + tx.amount;
          } else if (tx.isIncome) {
            totalIncome += tx.amount;
          }
        }
      },
    );
    if (txError) return;

    PlanningEntity? planning;
    bool planError = false;
    final planResult = await getPlanning(userId, mid);
    planResult.fold(
      (f) {
        planError = true;
        emit(PlanningError(f.message));
      },
      (p) => planning = p,
    );
    if (planError) return;

    final expenseCategories = categories!
        .where((c) => c.type == TransactionType.expense)
        .toList();

    final insights = planning != null
        ? PlanningEngine.generateInsights(
            plan: planning!,
            spentByCategory: spentByCategory,
            categories: expenseCategories,
            totalIncome: totalIncome,
          )
        : <SpendingInsight>[];

    emit(PlanningLoaded(
      planning: planning,
      spentByCategory: spentByCategory,
      insights: insights,
      categories: expenseCategories,
      totalIncome: totalIncome,
      currentMonth: targetMonth,
    ));
  }

  Future<void> save(String userId, PlanningEntity planning) async {
    final result = await savePlanning(planning);
    result.fold(
      (f) => emit(PlanningError(f.message)),
      (_) {
        final month = DateTime(
          int.parse(planning.id.split('-')[0]),
          int.parse(planning.id.split('-')[1]),
        );
        load(userId, month: month);
      },
    );
  }

  void changeMonth(String userId, DateTime month) => load(userId, month: month);
}
