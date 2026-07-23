import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/sync/sync_engine.dart';
import 'package:findiary/core/di/injection.dart';
import 'package:findiary/features/families/bloc/scope_cubit.dart';
import 'bloc/transaction_list_bloc.dart';
import 'bloc/transaction_list_event.dart';
import 'bloc/transaction_list_state.dart';
import 'widgets/transaction_tile.dart';
import 'transaction_form_sheet.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionListBloc(
        transactionDao: sl<TransactionDao>(),
        syncEngine: sl<SyncEngine>(),
      ),
      child: const _TransactionListView(),
    );
  }
}

class _TransactionListView extends StatefulWidget {
  const _TransactionListView();

  @override
  State<_TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<_TransactionListView> {
  @override
  void initState() {
    super.initState();
    final scope = context.read<ScopeCubit>().state;
    context.read<TransactionListBloc>().add(TransactionListRequested(
      familyId: scope.isPersonal ? null : scope.scopeId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: BlocBuilder<TransactionListBloc, TransactionListState>(
        builder: (context, state) {
          if (state is TransactionListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionListLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                final scope = context.read<ScopeCubit>().state;
                context.read<TransactionListBloc>().add(TransactionListRequested(
                  familyId: scope.isPersonal ? null : scope.scopeId,
                ));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SegmentedButton<String?>(
                        segments: const [
                          ButtonSegment(value: null, label: Text('All')),
                          ButtonSegment(value: 'income', label: Text('Income')),
                          ButtonSegment(value: 'expense', label: Text('Expense')),
                        ],
                        selected: {state.typeFilter},
                        onSelectionChanged: (v) {
                          context
                              .read<TransactionListBloc>()
                              .add(TransactionListFilterChanged(v.first));
                        },
                      ),
                    ),
                  ),
                  if (state.transactions.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No transactions yet')),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TransactionTile(
                          transaction: state.transactions[i],
                          onTap: () => TransactionFormSheet.show(
                            context,
                            transaction: state.transactions[i],
                          ),
                        ),
                        childCount: state.transactions.length,
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TransactionFormSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
