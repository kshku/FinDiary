import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:findiary/core/database/database.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final fmt = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
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
      title: Text(
        transaction.description ?? transaction.categoryId,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(transaction.date, style: Theme.of(context).textTheme.bodySmall),
      trailing: Text(
        '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      onTap: onTap,
    );
  }
}
