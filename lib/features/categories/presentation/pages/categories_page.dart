import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../injection/injection_container.dart';
import '../../../../router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/categories_bloc.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final authState = context.read<AuthBloc>().state;
        final bloc = sl<CategoriesBloc>();
        if (authState is AuthAuthenticated) {
          bloc.add(CategoriesLoadRequested(authState.user.uid));
        }
        return bloc;
      },
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.categories),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push(AppRoutes.addCategory),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Despesas'), Tab(text: 'Receitas')],
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
          ),
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (state is CategoriesLoaded) {
              return TabBarView(
                children: [
                  _CategoryList(categories: state.expenseCategories),
                  _CategoryList(categories: state.incomeCategories),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryEntity> categories;

  const _CategoryList({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const EmptyState(
        icon: Icons.category_outlined,
        title: 'Nenhuma categoria',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: categories.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (_, index) {
        final cat = categories[index];
        final color = Color(
            int.tryParse(cat.color.replaceAll('#', '0xFF')) ?? 0xFF94A3B8);
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(Icons.circle, color: color, size: 14),
          ),
          title: Text(cat.name, style: AppTextStyles.bodyLarge),
          subtitle: cat.isDefault
              ? Text('Padrão', style: AppTextStyles.labelSmall)
              : null,
          trailing: !cat.isDefault
              ? IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<CategoriesBloc>().add(CategoriesDeleteRequested(
                            userId: authState.user.uid,
                            categoryId: cat.id,
                          ));
                    }
                  },
                )
              : null,
        );
      },
    );
  }
}
