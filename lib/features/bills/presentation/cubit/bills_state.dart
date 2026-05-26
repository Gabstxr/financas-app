part of 'bills_cubit.dart';

abstract class BillsState extends Equatable {
  const BillsState();
  @override
  List<Object?> get props => [];
}

class BillsInitial extends BillsState {}

class BillsLoading extends BillsState {}

class BillsLoaded extends BillsState {
  final List<BillEntity> bills;
  const BillsLoaded(this.bills);

  List<BillEntity> get overdue =>
      bills.where((b) => b.isOverdue).toList();

  List<BillEntity> get dueSoon =>
      bills.where((b) => b.isDueSoon && !b.isOverdue).toList();

  List<BillEntity> get upcoming =>
      bills.where((b) => !b.isPaid && !b.isOverdue && !b.isDueSoon).toList();

  List<BillEntity> get paid =>
      bills.where((b) => b.isPaid).toList();

  @override
  List<Object?> get props => [bills];
}

class BillsError extends BillsState {
  final String message;
  const BillsError(this.message);
  @override
  List<Object?> get props => [message];
}
