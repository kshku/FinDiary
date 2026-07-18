import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/transaction_dao.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/di/injection.dart';

class TransactionFormSheet extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormSheet({super.key, this.transaction});

  static void show(BuildContext context, {Transaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionFormSheet(transaction: transaction),
    );
  }

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _categoryDao = sl<CategoryDao>();
  late String _type;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late String _date;
  String? _categoryId;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _type = widget.transaction?.type ?? 'income';
    _amountCtrl = TextEditingController(
      text: widget.transaction != null ? widget.transaction!.amount.toString() : '',
    );
    _descCtrl = TextEditingController(text: widget.transaction?.description ?? '');
    _date = widget.transaction?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _categoryId = widget.transaction?.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryDao.listCategories(type: _type);
    setState(() => _categories = cats);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dao = sl<TransactionDao>();
    final now = DateTime.now().toIso8601String();
    final id = widget.transaction?.id ?? const Uuid().v4();
    await dao.upsertTransaction(TransactionsCompanion(
      id: Value(id),
      type: Value(_type),
      amount: Value(double.parse(_amountCtrl.text)),
      currency: const Value('INR'),
      categoryId: Value(_categoryId ?? ''),
      date: Value(_date),
      description: Value(_descCtrl.text),
      createdBy: Value(widget.transaction?.createdBy ?? ''),
      createdAt: Value(widget.transaction?.createdAt ?? now),
      updatedAt: Value(now),
    ));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'income', label: Text('Income')),
                ButtonSegment(value: 'expense', label: Text('Expense')),
              ],
              selected: {_type},
              onSelectionChanged: (v) {
                setState(() => _type = v.first);
                _loadCategories();
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v != null && double.tryParse(v) != null && double.parse(v) > 0
                      ? null
                      : 'Enter a valid amount',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Date'),
              controller: TextEditingController(text: _date),
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_date),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _date = DateFormat('yyyy-MM-dd').format(picked));
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) {
                final ledger = c.name[0].toUpperCase();
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: c.color != null
                            ? Color(int.parse(c.color!.replaceFirst('#', '0xFF')))
                            : Theme.of(context).colorScheme.primaryContainer,
                        radius: 14,
                        child: Text(ledger, style: const TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Text(c.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: Text(widget.transaction == null ? 'Add' : 'Save'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
