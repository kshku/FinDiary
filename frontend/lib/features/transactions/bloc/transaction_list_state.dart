import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class TransactionListState extends Equatable {
  const TransactionListState();

  @override
  List<Object?> get props => [];
}

final class TransactionListInitial extends TransactionListState {
  const TransactionListInitial();
}

final class TransactionListLoading extends TransactionListState {
  const TransactionListLoading();
}

final class TransactionListLoaded extends TransactionListState {
  final List<Transaction> transactions;
  final String? typeFilter;

  const TransactionListLoaded({required this.transactions, this.typeFilter});

  @override
  List<Object?> get props => [transactions, typeFilter];
}
