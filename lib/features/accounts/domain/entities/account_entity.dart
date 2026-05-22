import 'package:equatable/equatable.dart';

enum AccountType { checking, savings, cash, credit, investment }

extension AccountTypeExtension on AccountType {
  String get label => switch (this) {
        AccountType.checking => 'Conta Corrente',
        AccountType.savings => 'Poupança',
        AccountType.cash => 'Dinheiro',
        AccountType.credit => 'Cartão de Crédito',
        AccountType.investment => 'Investimento',
      };

  String get firestoreValue => name;

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AccountType.checking,
    );
  }
}

class AccountEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AccountType type;
  final int balance;
  final int initialBalance;
  final String color;
  final String icon;
  final bool isActive;
  final DateTime createdAt;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.initialBalance,
    required this.color,
    required this.icon,
    this.isActive = true,
    required this.createdAt,
  });

  AccountEntity copyWith({
    String? id,
    String? userId,
    String? name,
    AccountType? type,
    int? balance,
    int? initialBalance,
    String? color,
    String? icon,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, type, balance, color, icon, isActive];
}
