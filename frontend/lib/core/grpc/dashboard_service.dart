import '../../generated/findiary/v1/dashboard_service.pb.dart';
import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart';

class DashboardGrpcService {
  final DashboardServiceClient _client;

  DashboardGrpcService(this._client);

  Future<GetDashboardResponse> getDashboard({String? familyId, int months = 6}) async {
    final request = GetDashboardRequest(
      familyId: familyId,
      months: months,
    );
    return _client.getDashboard(request);
  }
}
