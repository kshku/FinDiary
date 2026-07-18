import 'package:grpc/grpc.dart';
import 'auth_interceptor.dart';
import '../../generated/findiary/v1/sync_service.pbgrpc.dart' as sync_grpc;
import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart' as dashboard_grpc;

class GrpcClient {
  late final ClientChannel _channel;
  late final AuthInterceptor _authInterceptor;

  GrpcClient({String host = 'localhost', int port = 9090}) {
    _authInterceptor = AuthInterceptor();
    _channel = ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }

  ClientChannel get channel => _channel;
  AuthInterceptor get authInterceptor => _authInterceptor;

  void setToken(String token) {
    _authInterceptor.setToken(token);
  }

  void clearToken() {
    _authInterceptor.clearToken();
  }

  sync_grpc.SyncServiceClient createSyncServiceClient() {
    return sync_grpc.SyncServiceClient(_channel);
  }

  dashboard_grpc.DashboardServiceClient createDashboardServiceClient() {
    return dashboard_grpc.DashboardServiceClient(_channel);
  }

  Future<void> shutdown() async {
    await _channel.shutdown();
  }
}
