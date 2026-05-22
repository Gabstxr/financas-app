part of 'accounts_bloc.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();
  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final List<AccountEntity> accounts;
  const AccountsLoaded(this.accounts);

  int get totalBalance => accounts.fold(0, (sum, a) => sum + a.balance);

  @override
  List<Object> get props => [accounts];
}

class AccountsError extends AccountsState {
  final String message;
  const AccountsError(this.message);
  @override
  List<Object> get props => [message];
}
