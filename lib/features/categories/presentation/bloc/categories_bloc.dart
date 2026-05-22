import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategories getCategories;
  final AddCategory addCategory;
  final DeleteCategory deleteCategory;

  CategoriesBloc({
    required this.getCategories,
    required this.addCategory,
    required this.deleteCategory,
  }) : super(CategoriesInitial()) {
    on<CategoriesLoadRequested>(_onLoad);
    on<CategoriesAddRequested>(_onAdd);
    on<CategoriesDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(CategoriesLoadRequested event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    final result = await getCategories(event.userId);
    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (categories) => emit(CategoriesLoaded(categories)),
    );
  }

  Future<void> _onAdd(CategoriesAddRequested event, Emitter<CategoriesState> emit) async {
    final current = state is CategoriesLoaded
        ? (state as CategoriesLoaded).categories
        : <CategoryEntity>[];
    final result = await addCategory(event.category);
    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (category) => emit(CategoriesLoaded([...current, category])),
    );
  }

  Future<void> _onDelete(CategoriesDeleteRequested event, Emitter<CategoriesState> emit) async {
    if (state is! CategoriesLoaded) return;
    final current = (state as CategoriesLoaded).categories;
    final result = await deleteCategory(event.userId, event.categoryId);
    result.fold(
      (failure) => emit(CategoriesError(failure.message)),
      (_) => emit(CategoriesLoaded(
          current.where((c) => c.id != event.categoryId).toList())),
    );
  }
}
