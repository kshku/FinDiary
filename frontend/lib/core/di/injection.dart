import 'package:get_it/get_it.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import '../client/grpc_client.dart';
import '../database/database.dart';
import '../database/daos/transaction_dao.dart';
import '../database/daos/sync_meta_dao.dart';
import '../sync/sync_service.dart';
import '../sync/sync_engine.dart';

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

  final database = AppDatabase();
  sl.registerLazySingleton<AppDatabase>(() => database);

  final syncMetaDao = SyncMetaDao(database);
  sl.registerLazySingleton<SyncMetaDao>(() => syncMetaDao);

  final transactionDao = TransactionDao(database);
  sl.registerLazySingleton<TransactionDao>(() => transactionDao);

  final syncGrpcClient = grpcClient.createSyncServiceClient();
  final syncService = SyncService(
    (request) => syncGrpcClient.sync(request),
  );
  sl.registerLazySingleton<SyncService>(() => syncService);

  final syncEngine = SyncEngine(
    syncService: syncService,
    syncMetaDao: syncMetaDao,
    transactionDao: transactionDao,
    scopeId: 'personal',
    scopeType: 'personal',
  );
  sl.registerLazySingleton<SyncEngine>(() => syncEngine);
}
