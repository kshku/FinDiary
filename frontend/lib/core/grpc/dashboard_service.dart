import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart';

class DashboardGrpcService {
  final Future<GetDashboardResponse> Function(GetDashboardRequest) _perform;

  DashboardGrpcService._(this._perform);

  factory DashboardGrpcService.fromClient(DashboardServiceClient client) {
    return DashboardGrpcService._((req) => client.getDashboard(req));
  }

  factory DashboardGrpcService.fromFunction(
    Future<GetDashboardResponse> Function(GetDashboardRequest) perform,
  ) {
    return DashboardGrpcService._(perform);
  }

  Future<GetDashboardResponse> getDashboard({String? familyId, int months = 6}) {
    final request = GetDashboardRequest(
      familyId: familyId,
      months: months,
    );
    return _perform(request);
  }
}
