import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/grpc/dashboard_service.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_event.dart';
import 'package:findiary/features/dashboard/bloc/dashboard_state.dart';

class MockTransactionDao extends Mock implements TransactionDao {}
class MockDashboardGrpcService extends Mock implements DashboardGrpcService {}

void main() {
  late MockTransactionDao mockTransactionDao;
  late MockDashboardGrpcService mockDashboardGrpcService;

  setUp(() {
    mockTransactionDao = MockTransactionDao();
    mockDashboardGrpcService = MockDashboardGrpcService();
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits loading then loaded with totals',
      setUp: () {
        when(() => mockTransactionDao.sumTransactions(type: 'income'))
            .thenAnswer((_) async => 500.0);
        when(() => mockTransactionDao.sumTransactions(type: 'expense'))
            .thenAnswer((_) async => 300.0);
        when(() => mockTransactionDao.listTransactions(limit: 10))
            .thenAnswer((_) async => []);
        when(() => mockDashboardGrpcService.getDashboard())
            .thenAnswer((_) async => GetDashboardResponse());
      },
      build: () => DashboardBloc(
        transactionDao: mockTransactionDao,
        dashboardGrpcService: mockDashboardGrpcService,
      ),
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
        when(() => mockTransactionDao.sumTransactions(type: 'income'))
            .thenThrow(Exception('db error'));
      },
      build: () => DashboardBloc(
        transactionDao: mockTransactionDao,
        dashboardGrpcService: mockDashboardGrpcService,
      ),
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

    blocTest<DashboardBloc, DashboardState>(
      'loads monthly summaries from server',
      setUp: () {
        when(() => mockTransactionDao.sumTransactions(type: 'income'))
            .thenAnswer((_) async => 50000.0);
        when(() => mockTransactionDao.sumTransactions(type: 'expense'))
            .thenAnswer((_) async => 30000.0);
        when(() => mockTransactionDao.listTransactions(limit: 10))
            .thenAnswer((_) async => []);
        when(() => mockDashboardGrpcService.getDashboard())
            .thenAnswer((_) async => GetDashboardResponse(
                  totalIncome: 50000,
                  totalExpense: 30000,
                  monthly: [
                    MonthlySummary(
                      yearMonth: '2026-07',
                      totalIncome: 50000,
                      totalExpense: 30000,
                    ),
                  ],
                ));
      },
      build: () => DashboardBloc(
        transactionDao: mockTransactionDao,
        dashboardGrpcService: mockDashboardGrpcService,
      ),
      act: (bloc) => bloc.add(const DashboardRequested()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>()
            .having((s) => s.monthlySummaries.length, 'has monthly data', 1),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'requests dashboard with family scope',
      setUp: () {
        when(() => mockTransactionDao.sumTransactions(type: 'income', familyId: 'fam-1'))
            .thenAnswer((_) async => 1000.0);
        when(() => mockTransactionDao.sumTransactions(type: 'expense', familyId: 'fam-1'))
            .thenAnswer((_) async => 500.0);
        when(() => mockTransactionDao.listTransactions(limit: 10, familyId: 'fam-1'))
            .thenAnswer((_) async => []);
        when(() => mockDashboardGrpcService.getDashboard(familyId: 'fam-1'))
            .thenAnswer((_) async => GetDashboardResponse());
      },
      build: () => DashboardBloc(
        transactionDao: mockTransactionDao,
        dashboardGrpcService: mockDashboardGrpcService,
      ),
      act: (b) => b.add(const DashboardRequested(scopeId: 'fam-1', scopeType: 'family')),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardLoaded>(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'still loads when server is offline',
      setUp: () {
        when(() => mockTransactionDao.sumTransactions(type: 'income'))
            .thenAnswer((_) async => 500.0);
        when(() => mockTransactionDao.sumTransactions(type: 'expense'))
            .thenAnswer((_) async => 300.0);
        when(() => mockTransactionDao.listTransactions(limit: 10))
            .thenAnswer((_) async => []);
        when(() => mockDashboardGrpcService.getDashboard())
            .thenThrow(Exception('unavailable'));
      },
      build: () => DashboardBloc(
        transactionDao: mockTransactionDao,
        dashboardGrpcService: mockDashboardGrpcService,
      ),
      act: (bloc) => bloc.add(const DashboardRequested()),
      expect: () => [
        const DashboardLoading(),
        const DashboardLoaded(
          totalIncome: 500,
          totalExpense: 300,
          monthlySummaries: [],
          recentTransactions: [],
        ),
      ],
    );
  });
}
