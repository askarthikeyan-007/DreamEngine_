import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dream_engine_ai/core/services/sqlite_service.dart';
import 'package:dream_engine_ai/core/state/engine_state.dart';
import 'package:dream_engine_ai/presentation/launcher_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Warm up/initialize local SQLite database on startup
    await SqliteService.database;
  } catch (e) {
    debugPrint("Database initialization warning: $e");
  }
  runApp(const DreamEngineApp());
}

class DreamEngineApp extends StatelessWidget {
  const DreamEngineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EngineState(),
      child: Consumer<EngineState>(
        builder: (context, state, _) {
          final isLight = state.currentTheme == AppTheme.appleVision;
          return MaterialApp(
            title: 'DreamEngine',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: isLight ? Brightness.light : Brightness.dark,
              scaffoldBackgroundColor: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF020204),
              useMaterial3: true,
            ),
            home: const LauncherView(),
          );
        },
      ),
    );
  }
}
