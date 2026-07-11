import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> recentTransactions;

  const DashboardLoaded({
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [totalIncome, totalExpense, recentTransactions];
}
