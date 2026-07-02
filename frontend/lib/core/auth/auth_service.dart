import 'package:fixnum/fixnum.dart';
import '../../generated/findiary/v1/auth_service.pbgrpc.dart';
import '../client/grpc_client.dart';
import 'token_storage.dart';

class AuthService {
  final GrpcClient _grpcClient;
  final TokenStorage _tokenStorage;

  late final AuthServiceClient _stub;

  AuthService({
    required GrpcClient grpcClient,
    required TokenStorage tokenStorage,
  })  : _grpcClient = grpcClient,
        _tokenStorage = tokenStorage {
    _stub = AuthServiceClient(
      _grpcClient.channel,
      interceptors: [_grpcClient.authInterceptor],
    );
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.isAccessTokenValid();
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final request = RegisterRequest()
      ..email = email
      ..password = password
      ..displayName = displayName;
    final response = await _stub.register(request);
    await _handleAuthResponse(response);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest()
      ..email = email
      ..password = password;
    final response = await _stub.login(request);
    await _handleAuthResponse(response);
  }

  Future<void> refreshToken() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null) throw Exception('No refresh token');
    final request = RefreshTokenRequest()..refreshToken = refresh;
    final response = await _stub.refreshToken(request);
    await _handleAuthResponse(response);
  }

  Future<void> logout() async {
    _grpcClient.clearToken();
    await _tokenStorage.clearTokens();
  }

  Future<void> _handleAuthResponse(
    Object response,
  ) async {
    String accessToken;
    String refreshToken;
    Int64 accessExpiresAt;
    Int64 refreshExpiresAt;

    if (response is RegisterResponse) {
      accessToken = response.accessToken;
      refreshToken = response.refreshToken;
      accessExpiresAt = response.accessExpiresAt;
      refreshExpiresAt = response.refreshExpiresAt;
    } else if (response is LoginResponse) {
      accessToken = response.accessToken;
      refreshToken = response.refreshToken;
      accessExpiresAt = response.accessExpiresAt;
      refreshExpiresAt = response.refreshExpiresAt;
    } else if (response is RefreshTokenResponse) {
      accessToken = response.accessToken;
      refreshToken = response.refreshToken;
      accessExpiresAt = response.accessExpiresAt;
      refreshExpiresAt = response.refreshExpiresAt;
    } else {
      throw Exception('Unknown response type');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpiresAt: accessExpiresAt.toInt(),
      refreshExpiresAt: refreshExpiresAt.toInt(),
    );
    _grpcClient.setToken(accessToken);
  }
}
