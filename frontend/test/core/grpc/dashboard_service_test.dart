import 'package:flutter_test/flutter_test.dart';
import 'package:grpc/grpc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/grpc/dashboard_service.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pbgrpc.dart' as grpc;
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';

class MockDashboardClient extends Mock implements grpc.DashboardServiceClient {}

void main() {
  late MockDashboardClient mockClient;
  late DashboardGrpcService service;

  setUp(() {
    mockClient = MockDashboardClient();
    service = DashboardGrpcService(mockClient);
  });

  group('DashboardGrpcService', () {
    test('getDashboard returns response', () async {
      final response = GetDashboardResponse(
        totalIncome: 50000,
        totalExpense: 30000,
        monthly: [MonthlySummary(yearMonth: '2026-07', totalIncome: 50000, totalExpense: 30000)],
      );
      when(() => mockClient.getDashboard(any())).thenAnswer(
        (_) async => ResponseFuture<GetDashboardResponse>(Future.value(response)),
      );

      final result = await service.getDashboard();
      expect(result.totalIncome, 50000);
      expect(result.totalExpense, 30000);
      expect(result.monthly.length, 1);
    });
  });
}
