import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/sync/sync_engine.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const FinDiaryApp());
  sl<SyncEngine>().start();
}
