import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/grpc/dashboard_service.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionDao _transactionDao;
  final DashboardGrpcService _dashboardGrpcService;

  DashboardBloc({
    required this._transactionDao,
    required this._dashboardGrpcService,
  }) : super(const DashboardInitial()) {
    on<DashboardRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final income = await _transactionDao.sumTransactions(
        type: 'income', familyId: event.scopeId,
      );
      final expense = await _transactionDao.sumTransactions(
        type: 'expense', familyId: event.scopeId,
      );
      final recent = await _transactionDao.listTransactions(
        limit: 10, familyId: event.scopeId,
      );

      List<MonthlySummary> monthly = [];
      if (event.scopeId != null) {
        try {
          final serverData = await _dashboardGrpcService.getDashboard(familyId: event.scopeId);
          monthly = serverData.monthly;
        } catch (_) {}
      } else {
        try {
          final serverData = await _dashboardGrpcService.getDashboard();
          monthly = serverData.monthly;
        } catch (_) {}
      }

      emit(DashboardLoaded(
        totalIncome: income,
        totalExpense: expense,
        monthlySummaries: monthly,
        recentTransactions: recent,
      ));
    } catch (_) {
      emit(const DashboardLoaded(
        totalIncome: 0,
        totalExpense: 0,
        recentTransactions: [],
      ));
    }
  }
}
