import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:financas_app/core/errors/failures.dart';
import 'package:financas_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:financas_app/features/transactions/domain/usecases/add_transaction.dart';
import 'package:financas_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:financas_app/features/transactions/domain/usecases/get_transactions_by_month.dart';
import 'package:financas_app/features/transactions/domain/usecases/update_transaction.dart';
import 'package:financas_app/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTransactionsByMonth extends Mock implements GetTransactionsByMonth {}
class MockAddTransaction extends Mock implements AddTransaction {}
class MockUpdateTransaction extends Mock implements UpdateTransaction {}
class MockDeleteTransaction extends Mock implements DeleteTransaction {}

final _tTransaction = TransactionEntity(
  id: 'txn-1',
  userId: 'uid-1',
  type: FullTransactionType.expense,
  amount: 5000,
  description: 'Mercado',
  categoryId: 'cat-1',
  accountId: 'acc-1',
  date: DateTime(2025, 5, 10),
  createdAt: DateTime(2025, 5, 10),
  updatedAt: DateTime(2025, 5, 10),
  categoryName: 'Alimentação',
);

void main() {
  late TransactionsBloc bloc;
  late MockGetTransactionsByMonth mockGet;
  late MockAddTransaction mockAdd;
  late MockUpdateTransaction mockUpdate;
  late MockDeleteTransaction mockDelete;

  setUp(() {
    mockGet = MockGetTransactionsByMonth();
    mockAdd = MockAddTransaction();
    mockUpdate = MockUpdateTransaction();
    mockDelete = MockDeleteTransaction();

    bloc = TransactionsBloc(
      getTransactionsByMonth: mockGet,
      addTransaction: mockAdd,
      updateTransaction: mockUpdate,
      deleteTransaction: mockDelete,
    );
  });

  tearDown(() => bloc.close());

  group('TransactionsLoadRequested', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'emite [Loading, Loaded] com lista de transações',
      build: () {
        when(() => mockGet('uid-1', 2025, 5))
            .thenAnswer((_) async => Right([_tTransaction]));
        return bloc;
      },
      act: (b) => b.add(const TransactionsLoadRequested(
          userId: 'uid-1', year: 2025, month: 5)),
      expect: () => [
        isA<TransactionsLoading>(),
        isA<TransactionsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockGet('uid-1', 2025, 5)).called(1);
      },
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'emite [Loading, Error] quando falha',
      build: () {
        when(() => mockGet(any(), any(), any()))
            .thenAnswer((_) async => const Left(ServerFailure()));
        return bloc;
      },
      act: (b) => b.add(const TransactionsLoadRequested(
          userId: 'uid-1', year: 2025, month: 5)),
      expect: () => [isA<TransactionsLoading>(), isA<TransactionsError>()],
    );
  });

  group('TransactionsAddRequested', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'adiciona transação à lista existente',
      build: () {
        when(() => mockGet('uid-1', 2025, 5))
            .thenAnswer((_) async => Right([_tTransaction]));
        when(() => mockAdd(any()))
            .thenAnswer((_) async => Right(_tTransaction.copyWith(id: 'txn-2')));
        return bloc;
      },
      seed: () => TransactionsLoaded(
        transactions: [_tTransaction],
        year: 2025,
        month: 5,
      ),
      act: (b) => b.add(TransactionsAddRequested(_tTransaction)),
      expect: () => [
        isA<TransactionsLoaded>().having(
            (s) => s.transactions.length, 'length', 2),
      ],
    );
  });

  group('TransactionsDeleteRequested', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'remove transação da lista',
      build: () {
        when(() => mockDelete('uid-1', 'txn-1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => TransactionsLoaded(
        transactions: [_tTransaction],
        year: 2025,
        month: 5,
      ),
      act: (b) => b.add(const TransactionsDeleteRequested(
          userId: 'uid-1', transactionId: 'txn-1')),
      expect: () => [
        isA<TransactionsLoaded>().having(
            (s) => s.transactions.length, 'length', 0),
      ],
    );
  });

  group('TransactionsLoaded cálculos', () {
    test('calcula totalIncome e totalExpenses corretamente', () {
      final income = _tTransaction.copyWith(
          type: FullTransactionType.income, amount: 300000);
      final expense = _tTransaction.copyWith(
          type: FullTransactionType.expense, amount: 5000);

      final state = TransactionsLoaded(
        transactions: [income, expense],
        year: 2025,
        month: 5,
      );

      expect(state.totalIncome, 300000);
      expect(state.totalExpenses, 5000);
      expect(state.balance, 295000);
    });
  });
}
