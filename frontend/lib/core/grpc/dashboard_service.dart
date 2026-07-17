import '../../generated/findiary/v1/dashboard_service.pb.dart';
import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart';

class DashboardGrpcService {
  final Future<GetDashboardResponse> Function(GetDashboardRequest) _perform;

  DashboardGrpcService.fromClient(DashboardServiceClient client)
      : _perform = (req) => client.getDashboard(req);

  DashboardGrpcService.fromFunction(this._perform);

  Future<GetDashboardResponse> getDashboard({String? familyId, int months = 6}) {
    final request = GetDashboardRequest(
      familyId: familyId,
      months: months,
    );
    return _perform(request);
  }
}
