import 'package:grpc/grpc.dart';
import 'auth_interceptor.dart';
import '../../generated/findiary/v1/sync_service.pbgrpc.dart' as sync_grpc;
import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart' as dashboard_grpc;

class GrpcClient {
  late final ClientChannel _channel;
  late final AuthInterceptor _authInterceptor;

  GrpcClient({String? host, int? port})
      : host = host ?? const String.fromEnvironment('GRPC_HOST', defaultValue: 'localhost'),
        port = port ?? int.fromEnvironment('GRPC_PORT', defaultValue: 9090) {
    _authInterceptor = AuthInterceptor();
    _channel = ClientChannel(
      this.host,
      port: this.port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }

  final String host;
  final int port;

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
