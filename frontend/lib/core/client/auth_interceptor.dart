import 'package:grpc/grpc.dart';

class AuthInterceptor extends ClientInterceptor {
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    if (_token != null) {
      options = options.mergedWith(CallOptions(
        metadata: {'authorization': 'Bearer $_token'},
      ));
    }
    return invoker(method, request, options);
  }
}
