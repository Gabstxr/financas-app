part of 'categories_bloc.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();
  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends CategoriesState {}
class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryEntity> categories;
  const CategoriesLoaded(this.categories);

  List<CategoryEntity> get incomeCategories =>
      categories.where((c) => c.type == TransactionType.income).toList();

  List<CategoryEntity> get expenseCategories =>
      categories.where((c) => c.type == TransactionType.expense).toList();

  @override
  List<Object> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
  @override
  List<Object> get props => [message];
}
