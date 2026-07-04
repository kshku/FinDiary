import 'package:get_it/get_it.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import '../client/grpc_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final grpcClient = GrpcClient(host: 'localhost', port: 9090);
  sl.registerLazySingleton<GrpcClient>(() => grpcClient);

  final tokenStorage = TokenStorage();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);

  final authService = AuthService(
    grpcClient: grpcClient,
    tokenStorage: tokenStorage,
  );
  sl.registerLazySingleton<AuthService>(() => authService);
}
