import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/usecases/get_transactions_by_month.dart';

part 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final GetTransactionsByMonth getTransactionsByMonth;

  ReportsCubit({required this.getTransactionsByMonth}) : super(ReportsInitial());

  Future<void> load(String userId, {DateTime? month}) async {
    emit(ReportsLoading());
    final targetMonth = month ?? DateTime.now();
    final result = await getTransactionsByMonth(
        userId, targetMonth.year, targetMonth.month);
    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (transactions) => emit(ReportsLoaded(
        transactions: transactions,
        currentMonth: targetMonth,
      )),
    );
  }
}
