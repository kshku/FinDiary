import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionDao _transactionDao;

  DashboardBloc({required TransactionDao transactionDao})
      : _transactionDao = transactionDao,
        super(const DashboardInitial()) {
    on<DashboardRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final income = await _transactionDao.sumTransactions(type: 'income');
      final expense = await _transactionDao.sumTransactions(type: 'expense');
      final recent = await _transactionDao.listTransactions(limit: 10);
      emit(DashboardLoaded(
        totalIncome: income,
        totalExpense: expense,
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
