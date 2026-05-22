import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../accounts/domain/entities/account_entity.dart';

enum TransactionType { income, expense }

extension TransactionTypeExtension on TransactionType {
  String get label => this == TransactionType.income ? 'Receita' : 'Despesa';
  String get firestoreValue => name;
  Color get color => this == TransactionType.income
      ? const Color(0xFF10B981)
      : const Color(0xFFEF4444);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final TransactionType type;
  final String icon;
  final String color;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, type, icon, color];
}

// Categorias padrão do sistema
abstract class DefaultCategories {
  static List<Map<String, dynamic>> expense(String userId) => [
        {'name': 'Alimentação', 'icon': 'restaurant', 'color': '#EF4444'},
        {'name': 'Transporte', 'icon': 'directions_car', 'color': '#F59E0B'},
        {'name': 'Moradia', 'icon': 'home', 'color': '#3B82F6'},
        {'name': 'Saúde', 'icon': 'favorite', 'color': '#EC4899'},
        {'name': 'Educação', 'icon': 'school', 'color': '#8B5CF6'},
        {'name': 'Lazer', 'icon': 'sports_esports', 'color': '#06B6D4'},
        {'name': 'Vestuário', 'icon': 'checkroom', 'color': '#FF6B35'},
        {'name': 'Assinaturas', 'icon': 'subscriptions', 'color': '#84CC16'},
        {'name': 'Pets', 'icon': 'pets', 'color': '#14B8A6'},
        {'name': 'Outros', 'icon': 'category', 'color': '#94A3B8'},
      ].map((cat) => {...cat, 'userId': userId, 'type': 'expense'}).toList();

  static List<Map<String, dynamic>> income(String userId) => [
        {'name': 'Salário', 'icon': 'work', 'color': '#10B981'},
        {'name': 'Freelance', 'icon': 'laptop', 'color': '#34D399'},
        {'name': 'Investimentos', 'icon': 'trending_up', 'color': '#6EE7B7'},
        {'name': 'Presente', 'icon': 'card_giftcard', 'color': '#A7F3D0'},
        {'name': 'Outros', 'icon': 'add_circle', 'color': '#94A3B8'},
      ].map((cat) => {...cat, 'userId': userId, 'type': 'income'}).toList();
}
