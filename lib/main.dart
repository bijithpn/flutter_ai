import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'navigation/navigation_service.dart';
import 'services/services.dart';
import 'models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters for pose detection models
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(KeyPointAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(PoseDataAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(WorkoutSessionAdapter());
  }

  // Initialize AI services
  // Note: In production, you would load the API key from secure storage or environment
  await AIServiceManager().initialize();

  runApp(const FlutterAIMVPApp());
}

class FlutterAIMVPApp extends StatelessWidget {
  const FlutterAIMVPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..initializeTheme(),
        ),
        ChangeNotifierProvider(
          create: (context) => TrainerProvider(
            poseDetectionService: TensorFlowLitePoseService(),
            workoutRepository: HiveStorageRepository<WorkoutSession>(
              "workout_session",
            ),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Flutter AI MVP',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.home,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
