part of 'accounts_bloc.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();
  @override
  List<Object?> get props => [];
}

class AccountsLoadRequested extends AccountsEvent {
  final String userId;
  const AccountsLoadRequested(this.userId);
  @override
  List<Object> get props => [userId];
}

class AccountsAddRequested extends AccountsEvent {
  final AccountEntity account;
  const AccountsAddRequested(this.account);
  @override
  List<Object> get props => [account];
}

class AccountsUpdateRequested extends AccountsEvent {
  final AccountEntity account;
  const AccountsUpdateRequested(this.account);
  @override
  List<Object> get props => [account];
}

class AccountsDeleteRequested extends AccountsEvent {
  final String userId;
  final String accountId;
  const AccountsDeleteRequested({required this.userId, required this.accountId});
  @override
  List<Object> get props => [userId, accountId];
}
