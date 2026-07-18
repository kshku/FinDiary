import 'package:flutter_test/flutter_test.dart';
import 'package:findiary/core/grpc/dashboard_service.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';

void main() {
  group('DashboardGrpcService', () {
    test('getDashboard returns response', () async {
      final response = GetDashboardResponse(
        totalIncome: 50000,
        totalExpense: 30000,
        monthly: [MonthlySummary(yearMonth: '2026-07', totalIncome: 50000, totalExpense: 30000)],
      );
      final service = DashboardGrpcService.fromFunction((_) async => response);

      final result = await service.getDashboard();
      expect(result.totalIncome, 50000);
      expect(result.totalExpense, 30000);
      expect(result.monthly.length, 1);
    });
  });
}
