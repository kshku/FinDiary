import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'transaction_list_event.dart';
import 'transaction_list_state.dart';

class TransactionListBloc extends Bloc<TransactionListEvent, TransactionListState> {
  final TransactionDao _transactionDao;

  TransactionListBloc({
    required TransactionDao transactionDao,
    required SyncEngine syncEngine,
  })  : _transactionDao = transactionDao,
        super(const TransactionListInitial()) {
    on<TransactionListRequested>(_onRequested);
    on<TransactionListFilterChanged>(_onFilterChanged);
  }

  Future<void> _onRequested(
    TransactionListRequested event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(const TransactionListLoading());
    try {
      final type =
          state is TransactionListLoaded ? (state as TransactionListLoaded).typeFilter : null;
      final transactions = await _transactionDao.listTransactions(type: type);
      emit(TransactionListLoaded(transactions: transactions, typeFilter: type));
    } catch (_) {
      emit(TransactionListLoaded(transactions: [], typeFilter: null));
    }
  }

  Future<void> _onFilterChanged(
    TransactionListFilterChanged event,
    Emitter<TransactionListState> emit,
  ) async {
    emit(const TransactionListLoading());
    try {
      final transactions = await _transactionDao.listTransactions(type: event.type);
      emit(TransactionListLoaded(transactions: transactions, typeFilter: event.type));
    } catch (_) {
      emit(TransactionListLoaded(transactions: [], typeFilter: event.type));
    }
  }
}
