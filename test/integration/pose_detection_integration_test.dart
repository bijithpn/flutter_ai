import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_ai_mvp/screens/trainer_screen.dart';
import 'package:flutter_ai_mvp/providers/trainer_provider.dart';
import 'package:flutter_ai_mvp/services/services.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'dart:async';

import 'pose_detection_integration_test.mocks.dart';

@GenerateMocks([PoseDetectionService, StorageRepository])
void main() {
  group('Pose Detection Integration Tests', () {
    late MockPoseDetectionService mockPoseService;
    late MockStorageRepository<WorkoutSession> mockWorkoutRepository;
    late StreamController<PoseData> poseStreamController;

    setUp(() {
      mockPoseService = MockPoseDetectionService();
      mockWorkoutRepository = MockStorageRepository<WorkoutSession>();
      poseStreamController = StreamController<PoseData>.broadcast();

      when(
        mockPoseService.poseStream,
      ).thenAnswer((_) => poseStreamController.stream);
      when(mockPoseService.isDetecting).thenReturn(false);
      when(
        mockWorkoutRepository.loadAll(),
      ).thenAnswer((_) async => <WorkoutSession>[]);
    });

    tearDown(() {
      poseStreamController.close();
    });

    Widget createTestApp() {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => TrainerProvider(
            poseDetectionService: mockPoseService,
            workoutRepository: mockWorkoutRepository,
          ),
          child: const TrainerScreen(),
        ),
      );
    }

    group('TrainerScreen UI Flow', () {
      testWidgets('should display welcome screen initially', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());

        expect(find.text('AI Personal Trainer'), findsOneWidget);
        expect(
          find.text(
            'Get real-time pose detection and feedback during exercises to maintain proper form',
          ),
          findsOneWidget,
        );
        expect(find.text('Select Exercise'), findsOneWidget);
        expect(find.text('Start Training'), findsOneWidget);
      });

      testWidgets('should show exercise selection options', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());

        expect(find.text('General'), findsOneWidget);
        expect(find.text('Push-ups'), findsOneWidget);
        expect(find.text('Squats'), findsOneWidget);
        expect(find.text('Plank'), findsOneWidget);
      });

      testWidgets('should allow exercise selection', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestApp());

        // Tap on Push-ups
        await tester.tap(find.text('Push-ups'));
        await tester.pump();

        // Verify selection is updated (this would be visually indicated by different styling)
        expect(find.text('Push-ups'), findsOneWidget);
      });

      testWidgets('should initialize camera when start training is pressed', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        await tester.tap(find.text('Start Training'));
        await tester.pump();

        // Should show initializing state
        expect(find.text('Initializing...'), findsOneWidget);

        // Complete initialization
        await tester.pump();

        verify(mockPoseService.initialize()).called(1);
      });

      testWidgets('should show camera ready state after initialization', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump(); // Complete initialization

        expect(find.text('Camera Ready'), findsOneWidget);
        expect(find.text('Begin Exercise'), findsOneWidget);
      });

      testWidgets(
        'should start pose detection when begin exercise is pressed',
        (WidgetTester tester) async {
          when(mockPoseService.initialize()).thenAnswer((_) async {});
          when(mockPoseService.startDetection()).thenAnswer((_) async {});

          await tester.pumpWidget(createTestApp());

          // Initialize first
          await tester.tap(find.text('Start Training'));
          await tester.pump();
          await tester.pump();

          // Start detection
          await tester.tap(find.text('Begin Exercise'));
          await tester.pump();

          verify(mockPoseService.startDetection()).called(1);
          expect(find.text('Stop Training'), findsOneWidget);
        },
      );

      testWidgets('should display pose feedback during detection', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Start detection
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();

        // Add pose data
        final poseData = PoseData(
          keyPoints: _createMockKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(poseData);
        await tester.pump();

        // Should show feedback overlay with stats
        expect(find.text('00:00'), findsOneWidget); // Timer
        expect(find.text('0.0%'), findsOneWidget); // Accuracy (initially 0)
        expect(find.text('0/1'), findsOneWidget); // Good poses count
      });

      testWidgets('should stop detection when stop training is pressed', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});
        when(mockPoseService.stopDetection()).thenAnswer((_) async {});
        when(mockWorkoutRepository.save(any, any)).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Start and then stop detection
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();
        await tester.tap(find.text('Stop Training'));
        await tester.pump();

        verify(mockPoseService.stopDetection()).called(1);
        expect(
          find.text('Begin Exercise'),
          findsOneWidget,
        ); // Back to ready state
      });

      testWidgets('should handle initialization errors gracefully', (
        WidgetTester tester,
      ) async {
        when(
          mockPoseService.initialize(),
        ).thenThrow(Exception('Camera permission denied'));

        await tester.pumpWidget(createTestApp());

        await tester.tap(find.text('Start Training'));
        await tester.pump();

        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.textContaining('Camera permission denied'), findsOneWidget);
      });

      testWidgets('should allow retry after error', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenThrow(Exception('Camera error'));

        await tester.pumpWidget(createTestApp());

        await tester.tap(find.text('Start Training'));
        await tester.pump();

        expect(find.text('Error'), findsOneWidget);

        // Tap retry
        await tester.tap(find.text('Try Again'));
        await tester.pump();

        // Should be back to idle state
        expect(find.text('Start Training'), findsOneWidget);
      });
    });

    group('Exercise-Specific Feedback', () {
      testWidgets('should provide pushup-specific feedback', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Select pushup exercise
        await tester.tap(find.text('Push-ups'));
        await tester.pump();

        // Start detection
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();

        // Add pushup pose data
        final pushupPose = PoseData(
          keyPoints: _createPushupKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(pushupPose);
        await tester.pump();

        // Should show pushup-specific feedback
        expect(find.textContaining('push-up'), findsOneWidget);
      });

      testWidgets('should provide squat-specific feedback', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Select squat exercise
        await tester.tap(find.text('Squats'));
        await tester.pump();

        // Start detection
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();

        // Add squat pose data
        final squatPose = PoseData(
          keyPoints: _createSquatKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(squatPose);
        await tester.pump();

        // Should show squat-specific feedback
        expect(find.textContaining('squat'), findsOneWidget);
      });

      testWidgets('should provide plank-specific feedback', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Select plank exercise
        await tester.tap(find.text('Plank'));
        await tester.pump();

        // Start detection
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();

        // Add plank pose data
        final plankPose = PoseData(
          keyPoints: _createPlankKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(plankPose);
        await tester.pump();

        // Should show plank-specific feedback
        expect(find.textContaining('plank'), findsOneWidget);
      });
    });

    group('Session Tracking', () {
      testWidgets('should track session statistics', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Start detection
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();

        // Add multiple poses with different qualities
        final goodPose = PoseData(
          keyPoints: _createMockKeyPoints(confidence: 0.9),
          confidence: 0.9,
          timestamp: DateTime.now(),
        );

        final badPose = PoseData(
          keyPoints: _createMockKeyPoints(confidence: 0.3),
          confidence: 0.3,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(goodPose);
        await tester.pump();
        poseStreamController.add(badPose);
        await tester.pump();
        poseStreamController.add(goodPose);
        await tester.pump();

        // Should show updated statistics
        expect(find.text('66.7%'), findsOneWidget); // 2/3 good poses = 66.7%
        expect(find.text('2/3'), findsOneWidget); // 2 good out of 3 total
      });

      testWidgets('should save workout session on completion', (
        WidgetTester tester,
      ) async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});
        when(mockPoseService.stopDetection()).thenAnswer((_) async {});
        when(mockWorkoutRepository.save(any, any)).thenAnswer((_) async {});

        await tester.pumpWidget(createTestApp());

        // Complete a workout session
        await tester.tap(find.text('Start Training'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Begin Exercise'));
        await tester.pump();

        // Add some poses
        final pose = PoseData(
          keyPoints: _createMockKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );
        poseStreamController.add(pose);
        await tester.pump();

        // Stop session
        await tester.tap(find.text('Stop Training'));
        await tester.pump();

        // Should save the workout session
        verify(mockWorkoutRepository.save(any, any)).called(1);
      });
    });

    group('Workout History', () {
      testWidgets('should display workout history when available', (
        WidgetTester tester,
      ) async {
        final mockSession = WorkoutSession(
          id: '1',
          exerciseType: 'pushup',
          duration: const Duration(minutes: 5),
          poseHistory: [],
          correctPostureCount: 25,
          startTime: DateTime.now().subtract(const Duration(days: 1)),
        );

        when(
          mockWorkoutRepository.loadAll(),
        ).thenAnswer((_) async => [mockSession]);

        await tester.pumpWidget(createTestApp());

        // Should show last workout preview
        expect(find.text('Last Workout'), findsOneWidget);
        expect(find.text('PUSHUP'), findsOneWidget);
      });
    });
  });
}

// Helper functions to create mock keypoints for different exercises
List<KeyPoint> _createMockKeyPoints({double confidence = 0.8}) {
  return [
    KeyPoint(name: 'nose', x: 0.5, y: 0.3, confidence: confidence),
    KeyPoint(name: 'left_eye', x: 0.4, y: 0.2, confidence: confidence),
    KeyPoint(name: 'right_eye', x: 0.6, y: 0.2, confidence: confidence),
    KeyPoint(name: 'left_shoulder', x: 0.35, y: 0.35, confidence: confidence),
    KeyPoint(name: 'right_shoulder', x: 0.65, y: 0.35, confidence: confidence),
    KeyPoint(name: 'left_elbow', x: 0.25, y: 0.5, confidence: confidence),
    KeyPoint(name: 'right_elbow', x: 0.75, y: 0.5, confidence: confidence),
    KeyPoint(name: 'left_wrist', x: 0.2, y: 0.65, confidence: confidence),
    KeyPoint(name: 'right_wrist', x: 0.8, y: 0.65, confidence: confidence),
    KeyPoint(name: 'left_hip', x: 0.4, y: 0.7, confidence: confidence),
    KeyPoint(name: 'right_hip', x: 0.6, y: 0.7, confidence: confidence),
    KeyPoint(name: 'left_knee', x: 0.38, y: 0.85, confidence: confidence),
    KeyPoint(name: 'right_knee', x: 0.62, y: 0.85, confidence: confidence),
    KeyPoint(name: 'left_ankle', x: 0.36, y: 0.95, confidence: confidence),
    KeyPoint(name: 'right_ankle', x: 0.64, y: 0.95, confidence: confidence),
  ];
}

List<KeyPoint> _createPushupKeyPoints() {
  return [
    KeyPoint(name: 'left_shoulder', x: 0.35, y: 0.35, confidence: 0.9),
    KeyPoint(name: 'right_shoulder', x: 0.65, y: 0.35, confidence: 0.9),
    KeyPoint(name: 'left_elbow', x: 0.25, y: 0.5, confidence: 0.8),
    KeyPoint(name: 'right_elbow', x: 0.75, y: 0.5, confidence: 0.8),
    KeyPoint(
      name: 'left_wrist',
      x: 0.35,
      y: 0.65,
      confidence: 0.8,
    ), // Aligned with shoulders
    KeyPoint(
      name: 'right_wrist',
      x: 0.65,
      y: 0.65,
      confidence: 0.8,
    ), // Aligned with shoulders
    ..._createMockKeyPoints().where(
      (kp) =>
          !kp.name.contains('shoulder') &&
          !kp.name.contains('elbow') &&
          !kp.name.contains('wrist'),
    ),
  ];
}

List<KeyPoint> _createSquatKeyPoints() {
  return [
    KeyPoint(name: 'left_hip', x: 0.4, y: 0.75, confidence: 0.8), // Lower hips
    KeyPoint(name: 'right_hip', x: 0.6, y: 0.75, confidence: 0.8), // Lower hips
    KeyPoint(
      name: 'left_knee',
      x: 0.38,
      y: 0.7,
      confidence: 0.7,
    ), // Knees above hips
    KeyPoint(
      name: 'right_knee',
      x: 0.62,
      y: 0.7,
      confidence: 0.7,
    ), // Knees above hips
    KeyPoint(name: 'left_ankle', x: 0.36, y: 0.95, confidence: 0.6),
    KeyPoint(name: 'right_ankle', x: 0.64, y: 0.95, confidence: 0.6),
    ..._createMockKeyPoints().where(
      (kp) =>
          !kp.name.contains('hip') &&
          !kp.name.contains('knee') &&
          !kp.name.contains('ankle'),
    ),
  ];
}

List<KeyPoint> _createPlankKeyPoints() {
  return [
    KeyPoint(name: 'left_shoulder', x: 0.35, y: 0.4, confidence: 0.9),
    KeyPoint(name: 'right_shoulder', x: 0.65, y: 0.4, confidence: 0.9),
    KeyPoint(
      name: 'left_hip',
      x: 0.4,
      y: 0.4,
      confidence: 0.8,
    ), // Aligned with shoulders
    KeyPoint(
      name: 'right_hip',
      x: 0.6,
      y: 0.4,
      confidence: 0.8,
    ), // Aligned with shoulders
    KeyPoint(
      name: 'left_ankle',
      x: 0.36,
      y: 0.5,
      confidence: 0.6,
    ), // Straight line
    KeyPoint(
      name: 'right_ankle',
      x: 0.64,
      y: 0.5,
      confidence: 0.6,
    ), // Straight line
    ..._createMockKeyPoints().where(
      (kp) =>
          !kp.name.contains('shoulder') &&
          !kp.name.contains('hip') &&
          !kp.name.contains('ankle'),
    ),
  ];
}
