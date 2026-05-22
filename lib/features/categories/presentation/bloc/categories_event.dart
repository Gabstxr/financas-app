part of 'categories_bloc.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
  @override
  List<Object?> get props => [];
}

class CategoriesLoadRequested extends CategoriesEvent {
  final String userId;
  const CategoriesLoadRequested(this.userId);
  @override
  List<Object> get props => [userId];
}

class CategoriesAddRequested extends CategoriesEvent {
  final CategoryEntity category;
  const CategoriesAddRequested(this.category);
  @override
  List<Object> get props => [category];
}

class CategoriesDeleteRequested extends CategoriesEvent {
  final String userId;
  final String categoryId;
  const CategoriesDeleteRequested({required this.userId, required this.categoryId});
  @override
  List<Object> get props => [userId, categoryId];
}
