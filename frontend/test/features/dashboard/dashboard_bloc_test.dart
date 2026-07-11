import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_event.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_state.dart';

class MockTransactionDao extends Mock implements TransactionDao {}

void main() {
  late MockTransactionDao mockTransactionDao;

  setUp(() {
    mockTransactionDao = MockTransactionDao();
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits loading then loaded with totals',
      setUp: () {
        when(() => mockTransactionDao.countTransactions(type: 'income'))
            .thenAnswer((_) async => 500);
        when(() => mockTransactionDao.countTransactions(type: 'expense'))
            .thenAnswer((_) async => 300);
        when(() => mockTransactionDao.listTransactions(limit: 10))
            .thenAnswer((_) async => []);
      },
      build: () => DashboardBloc(transactionDao: mockTransactionDao),
      act: (bloc) => bloc.add(const DashboardRequested()),
      expect: () => [
        const DashboardLoading(),
        const DashboardLoaded(
          totalIncome: 500,
          totalExpense: 300,
          recentTransactions: [],
        ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'handles dao error gracefully',
      setUp: () {
        when(() => mockTransactionDao.countTransactions(type: 'income'))
            .thenThrow(Exception('db error'));
      },
      build: () => DashboardBloc(transactionDao: mockTransactionDao),
      act: (bloc) => bloc.add(const DashboardRequested()),
      expect: () => [
        const DashboardLoading(),
        const DashboardLoaded(
          totalIncome: 0,
          totalExpense: 0,
          recentTransactions: [],
        ),
      ],
    );
  });
}
