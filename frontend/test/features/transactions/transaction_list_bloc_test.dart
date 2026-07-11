import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/features/transactions/bloc/transaction_list_bloc.dart';
import 'package:findiary/features/transactions/bloc/transaction_list_event.dart';
import 'package:findiary/features/transactions/bloc/transaction_list_state.dart';

class MockTransactionDao extends Mock implements TransactionDao {}
class MockSyncEngine extends Mock implements SyncEngine {}

void main() {
  late MockTransactionDao mockTransactionDao;
  late MockSyncEngine mockSyncEngine;

  setUp(() {
    mockTransactionDao = MockTransactionDao();
    mockSyncEngine = MockSyncEngine();
  });

  group('TransactionListBloc', () {
    blocTest<TransactionListBloc, TransactionListState>(
      'loads transactions on requested',
      setUp: () {
        when(() => mockTransactionDao.listTransactions(type: null))
            .thenAnswer((_) async => []);
      },
      build: () => TransactionListBloc(
        transactionDao: mockTransactionDao,
        syncEngine: mockSyncEngine,
      ),
      act: (bloc) => bloc.add(const TransactionListRequested()),
      expect: () => [
        const TransactionListLoading(),
        const TransactionListLoaded(transactions: [], typeFilter: null),
      ],
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'handles dao error on requested',
      setUp: () {
        when(() => mockTransactionDao.listTransactions(type: null))
            .thenThrow(Exception('db error'));
      },
      build: () => TransactionListBloc(
        transactionDao: mockTransactionDao,
        syncEngine: mockSyncEngine,
      ),
      act: (bloc) => bloc.add(const TransactionListRequested()),
      expect: () => [
        const TransactionListLoading(),
        const TransactionListLoaded(transactions: [], typeFilter: null),
      ],
    );

    blocTest<TransactionListBloc, TransactionListState>(
      'filters by type on filter changed',
      setUp: () {
        when(() => mockTransactionDao.listTransactions(type: 'income'))
            .thenAnswer((_) async => []);
      },
      build: () => TransactionListBloc(
        transactionDao: mockTransactionDao,
        syncEngine: mockSyncEngine,
      ),
      act: (bloc) => bloc.add(const TransactionListFilterChanged('income')),
      expect: () => [
        const TransactionListLoading(),
        const TransactionListLoaded(transactions: [], typeFilter: 'income'),
      ],
    );
  });
}
