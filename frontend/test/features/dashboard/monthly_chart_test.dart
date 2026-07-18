import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:findiary/features/dashboard/widgets/monthly_chart.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';

void main() {
  group('MonthlyChart', () {
    testWidgets('renders nothing when empty', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MonthlyChart(summaries: []))));
      expect(find.byType(MonthlyChart), findsOneWidget);
    });

    testWidgets('renders chart with data', (tester) async {
      final summaries = [
        MonthlySummary(yearMonth: '2026-07', totalIncome: 50000, totalExpense: 30000),
        MonthlySummary(yearMonth: '2026-06', totalIncome: 40000, totalExpense: 25000),
      ];
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MonthlyChart(summaries: summaries))));
      expect(find.text('Monthly Overview'), findsOneWidget);
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Expense'), findsWidgets);
    });
  });
}
