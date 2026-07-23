import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage.dart';
import '../client/grpc_client.dart';
import '../database/database.dart';
import '../database/daos/transaction_dao.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/family_dao.dart';
import '../database/daos/sync_meta_dao.dart';
import '../grpc/family_service.dart';
import '../grpc/category_service.dart';
import '../grpc/transaction_service.dart';
import '../grpc/dashboard_service.dart';
import '../sync/sync_service.dart';
import '../network/connectivity_notifier.dart';
import '../sync/sync_engine.dart';
import '../theme/app_theme.dart';
import 'package:findiary/features/families/bloc/family_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(prefs));

  final grpcClient = GrpcClient();
  sl.registerLazySingleton<GrpcClient>(() => grpcClient);

  final tokenStorage = TokenStorage();
  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);

  final authService = AuthService(
    grpcClient: grpcClient,
    tokenStorage: tokenStorage,
  );
  sl.registerLazySingleton<AuthService>(() => authService);

  sl.registerLazySingleton<FamilyGrpcService>(() => FamilyGrpcService(grpcClient));
  sl.registerLazySingleton<FamilyBloc>(() => FamilyBloc(
    familyDao: sl<FamilyDao>(),
    familyGrpcService: sl<FamilyGrpcService>(),
  ));
  sl.registerLazySingleton<CategoryGrpcService>(() => CategoryGrpcService(grpcClient));
  sl.registerLazySingleton<TransactionGrpcService>(() => TransactionGrpcService(grpcClient));

  final database = AppDatabase();
  sl.registerLazySingleton<AppDatabase>(() => database);

  final syncMetaDao = SyncMetaDao(database);
  sl.registerLazySingleton<SyncMetaDao>(() => syncMetaDao);

  final categoryDao = CategoryDao(database);
  sl.registerLazySingleton<CategoryDao>(() => categoryDao);

  final transactionDao = TransactionDao(database);
  sl.registerLazySingleton<TransactionDao>(() => transactionDao);

  final familyDao = FamilyDao(database);
  sl.registerLazySingleton<FamilyDao>(() => familyDao);

  final connectivityNotifier = ConnectivityNotifier();
  sl.registerLazySingleton<ConnectivityNotifier>(() => connectivityNotifier);

  final syncGrpcClient = grpcClient.createSyncServiceClient();
  final syncService = SyncService(
    (request) => syncGrpcClient.sync(request),
  );
  sl.registerLazySingleton<SyncService>(() => syncService);

  final syncEngine = SyncEngine(
    syncService: syncService,
    syncMetaDao: syncMetaDao,
    transactionDao: transactionDao,
    categoryDao: categoryDao,
    connectivityNotifier: connectivityNotifier,
    scopeId: 'personal',
    scopeType: 'personal',
  );
  sl.registerLazySingleton<SyncEngine>(() => syncEngine);

  final dashboardGrpcClient = grpcClient.createDashboardServiceClient();
  sl.registerLazySingleton<DashboardGrpcService>(() => DashboardGrpcService.fromClient(dashboardGrpcClient));
}
