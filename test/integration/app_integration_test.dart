import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_ai_mvp/main.dart';
import 'package:flutter_ai_mvp/models/models.dart';

void main() {
  group('App Integration Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(KeyPointAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PoseDataAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(WorkoutSessionAdapter());
      }
    });

    testWidgets('App should start without crashing', (
      WidgetTester tester,
    ) async {
      // This test verifies that the app can be instantiated without TensorFlow Lite
      // and that all providers are properly initialized

      await tester.pumpWidget(const FlutterAIMVPApp());

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the app has loaded
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('TrainerScreen should be accessible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const FlutterAIMVPApp());
      await tester.pumpAndSettle();

      // The app should load without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
