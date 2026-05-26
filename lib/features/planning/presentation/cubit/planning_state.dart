part of 'planning_cubit.dart';

abstract class PlanningState extends Equatable {
  const PlanningState();

  @override
  List<Object?> get props => [];
}

class PlanningInitial extends PlanningState {}

class PlanningLoading extends PlanningState {}

class PlanningLoaded extends PlanningState {
  final PlanningEntity? planning;
  final Map<String, int> spentByCategory;
  final List<SpendingInsight> insights;
  final List<CategoryEntity> categories;
  final int totalIncome;
  final DateTime currentMonth;

  const PlanningLoaded({
    required this.planning,
    required this.spentByCategory,
    required this.insights,
    required this.categories,
    required this.totalIncome,
    required this.currentMonth,
  });

  int get totalSpent => spentByCategory.values.fold(0, (a, b) => a + b);

  @override
  List<Object?> get props => [
        planning,
        spentByCategory,
        insights,
        categories,
        totalIncome,
        currentMonth,
      ];
}

class PlanningError extends PlanningState {
  final String message;
  const PlanningError(this.message);

  @override
  List<Object?> get props => [message];
}
