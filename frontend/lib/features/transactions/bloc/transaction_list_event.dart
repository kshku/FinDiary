import 'package:equatable/equatable.dart';

sealed class TransactionListEvent extends Equatable {
  const TransactionListEvent();

  @override
  List<Object?> get props => [];
}

final class TransactionListRequested extends TransactionListEvent {
  final String? familyId;
  const TransactionListRequested({this.familyId});
  @override
  List<Object?> get props => [familyId];
}

final class TransactionListFilterChanged extends TransactionListEvent {
  final String? type;

  const TransactionListFilterChanged(this.type);

  @override
  List<Object?> get props => [type];
}
