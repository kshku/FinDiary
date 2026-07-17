import '../../generated/findiary/v1/dashboard_service.pb.dart';
import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart';

class DashboardGrpcService {
  final Future<GetDashboardResponse> Function(GetDashboardRequest) _perform;

  DashboardGrpcService(this._perform);

  factory DashboardGrpcService.fromClient(DashboardServiceClient client) {
    return DashboardGrpcService((req) => client.getDashboard(req));
  }

  Future<GetDashboardResponse> getDashboard({String? familyId, int months = 6}) {
    final request = GetDashboardRequest(
      familyId: familyId,
      months: months,
    );
    return _perform(request);
  }
}
