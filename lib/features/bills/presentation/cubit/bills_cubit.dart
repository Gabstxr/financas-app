import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bill_entity.dart';
import '../../domain/usecases/add_bill.dart';
import '../../domain/usecases/delete_bill.dart';
import '../../domain/usecases/get_bills.dart';
import '../../domain/usecases/mark_bill_paid.dart';
import '../../domain/usecases/update_bill.dart';

part 'bills_state.dart';

class BillsCubit extends Cubit<BillsState> {
  final GetBills getBills;
  final AddBill addBill;
  final UpdateBill updateBill;
  final DeleteBill deleteBill;
  final MarkBillPaid markBillPaid;

  BillsCubit({
    required this.getBills,
    required this.addBill,
    required this.updateBill,
    required this.deleteBill,
    required this.markBillPaid,
  }) : super(BillsInitial());

  Future<void> load(String userId) async {
    emit(BillsLoading());
    final result = await getBills(userId);
    result.fold(
      (f) => emit(BillsError(f.message)),
      (bills) => emit(BillsLoaded(bills)),
    );
  }

  Future<void> add(BillEntity bill) async {
    final result = await addBill(bill);
    result.fold(
      (f) => emit(BillsError(f.message)),
      (added) {
        final current = state is BillsLoaded
            ? (state as BillsLoaded).bills
            : <BillEntity>[];
        emit(BillsLoaded([...current, added]));
      },
    );
  }

  Future<void> update(BillEntity bill) async {
    final result = await updateBill(bill);
    result.fold(
      (f) => emit(BillsError(f.message)),
      (updated) {
        if (state is! BillsLoaded) return;
        final bills = (state as BillsLoaded)
            .bills
            .map((b) => b.id == updated.id ? updated : b)
            .toList();
        emit(BillsLoaded(bills));
      },
    );
  }

  Future<void> delete(String userId, String billId) async {
    final result = await deleteBill(userId, billId);
    result.fold(
      (f) => emit(BillsError(f.message)),
      (_) {
        if (state is! BillsLoaded) return;
        final bills = (state as BillsLoaded)
            .bills
            .where((b) => b.id != billId)
            .toList();
        emit(BillsLoaded(bills));
      },
    );
  }

  Future<void> markPaid(BillEntity bill, String userId) async {
    final result = await markBillPaid(bill);
    result.fold(
      (f) => emit(BillsError(f.message)),
      (_) => load(userId),
    );
  }
}
