import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/network/connectivity_notifier.dart';
import 'core/sync/sync_engine.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await sl<ConnectivityNotifier>().initialize();
  sl<SyncEngine>().start();
  runApp(const FinDiaryApp());
}
