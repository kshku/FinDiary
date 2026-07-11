import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/di/injection.dart';
import 'bloc/dashboard_bloc.dart';
import 'bloc/dashboard_event.dart';
import 'bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(transactionDao: sl<TransactionDao>()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('FinDiary')),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardLoaded) {
            final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const DashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Balance',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fmt.format(state.balance),
                            style: theme.textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _SummaryChip(
                                label: 'Income',
                                amount: state.totalIncome,
                                color: Colors.green,
                                fmt: fmt,
                              ),
                              const SizedBox(width: 12),
                              _SummaryChip(
                                label: 'Expense',
                                amount: state.totalExpense,
                                color: Colors.red,
                                fmt: fmt,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Transactions', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (state.recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No transactions yet')),
                    )
                  else
                    ...state.recentTransactions.map(
                      (t) => _TransactionRow(transaction: t, fmt: fmt),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final NumberFormat fmt;

  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              fmt.format(amount),
              style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final NumberFormat fmt;

  const _TransactionRow({required this.transaction, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isIncome ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
        child: Icon(
          isIncome ? Icons.trending_up : Icons.trending_down,
          color: isIncome ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(transaction.description ?? transaction.categoryId),
      subtitle: Text(transaction.date),
      trailing: Text(
        '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
