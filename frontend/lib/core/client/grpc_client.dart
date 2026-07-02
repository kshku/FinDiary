import 'package:grpc/grpc.dart';
import 'auth_interceptor.dart';

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

  Future<void> shutdown() async {
    await _channel.shutdown();
  }
}
