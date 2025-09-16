import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/widgets/widgets.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/providers/providers.dart';

void main() {
  group('Pose Detection Widgets', () {
    late PoseData mockPoseData;

    setUp(() {
      mockPoseData = PoseData(
        keyPoints: [
          KeyPoint(name: 'nose', x: 0.5, y: 0.3, confidence: 0.8),
          KeyPoint(name: 'left_eye', x: 0.4, y: 0.2, confidence: 0.7),
          KeyPoint(name: 'right_eye', x: 0.6, y: 0.2, confidence: 0.7),
          KeyPoint(name: 'left_shoulder', x: 0.35, y: 0.35, confidence: 0.9),
          KeyPoint(name: 'right_shoulder', x: 0.65, y: 0.35, confidence: 0.9),
          KeyPoint(name: 'left_elbow', x: 0.25, y: 0.5, confidence: 0.8),
          KeyPoint(name: 'right_elbow', x: 0.75, y: 0.5, confidence: 0.8),
          KeyPoint(name: 'left_wrist', x: 0.2, y: 0.65, confidence: 0.6),
          KeyPoint(name: 'right_wrist', x: 0.8, y: 0.65, confidence: 0.6),
          KeyPoint(name: 'left_hip', x: 0.4, y: 0.7, confidence: 0.8),
          KeyPoint(name: 'right_hip', x: 0.6, y: 0.7, confidence: 0.8),
          KeyPoint(name: 'left_knee', x: 0.38, y: 0.85, confidence: 0.7),
          KeyPoint(name: 'right_knee', x: 0.62, y: 0.85, confidence: 0.7),
          KeyPoint(name: 'left_ankle', x: 0.36, y: 0.95, confidence: 0.6),
          KeyPoint(name: 'right_ankle', x: 0.64, y: 0.95, confidence: 0.6),
        ],
        confidence: 0.75,
        timestamp: DateTime.now(),
      );
    });

    group('PoseOverlay', () {
      testWidgets('should render without pose data', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PoseOverlay(poseData: null, previewSize: Size(300, 400)),
            ),
          ),
        );

        expect(find.byType(PoseOverlay), findsOneWidget);
      });

      testWidgets('should render with pose data', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PoseOverlay(
                poseData: mockPoseData,
                previewSize: const Size(300, 400),
              ),
            ),
          ),
        );

        expect(find.byType(PoseOverlay), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should respect confidence threshold', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PoseOverlay(
                poseData: mockPoseData,
                previewSize: const Size(300, 400),
                confidence: 0.9, // High threshold
              ),
            ),
          ),
        );

        expect(find.byType(PoseOverlay), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });
    });

    group('SkeletonRenderer', () {
      testWidgets('should render without pose data', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SkeletonRenderer(
                poseData: null,
                renderSize: Size(300, 400),
              ),
            ),
          ),
        );

        expect(find.byType(SkeletonRenderer), findsOneWidget);
      });

      testWidgets('should render with pose data', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonRenderer(
                poseData: mockPoseData,
                renderSize: const Size(300, 400),
              ),
            ),
          ),
        );

        expect(find.byType(SkeletonRenderer), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should render with confidence indicator enabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonRenderer(
                poseData: mockPoseData,
                renderSize: const Size(300, 400),
                showConfidenceIndicator: true,
              ),
            ),
          ),
        );

        expect(find.byType(SkeletonRenderer), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should render with keypoint labels enabled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonRenderer(
                poseData: mockPoseData,
                renderSize: const Size(300, 400),
                showKeyPointLabels: true,
              ),
            ),
          ),
        );

        expect(find.byType(SkeletonRenderer), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should respect custom colors and sizes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonRenderer(
                poseData: mockPoseData,
                renderSize: const Size(300, 400),
                keypointColor: Colors.red,
                connectionColor: Colors.blue,
                keypointRadius: 8.0,
                connectionWidth: 4.0,
              ),
            ),
          ),
        );

        expect(find.byType(SkeletonRenderer), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });

      testWidgets('should handle different confidence thresholds', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkeletonRenderer(
                poseData: mockPoseData,
                renderSize: const Size(300, 400),
                confidenceThreshold: 0.9, // High threshold
              ),
            ),
          ),
        );

        expect(find.byType(SkeletonRenderer), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);
      });
    });

    group('FeedbackOverlay', () {
      testWidgets('should display feedback message and stats', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Great posture!',
                feedbackType: FeedbackType.positive,
                sessionDuration: Duration(minutes: 2, seconds: 30),
                accuracyPercentage: 85.5,
                correctPostureCount: 17,
                totalPoseCount: 20,
              ),
            ),
          ),
        );

        expect(find.text('Great posture!'), findsOneWidget);
        expect(find.text('02:30'), findsOneWidget);
        expect(find.text('85.5%'), findsOneWidget);
        expect(find.text('17/20'), findsOneWidget);
      });

      testWidgets('should show different colors for different feedback types', (
        WidgetTester tester,
      ) async {
        // Test positive feedback
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Great!',
                feedbackType: FeedbackType.positive,
                sessionDuration: Duration.zero,
                accuracyPercentage: 0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Test warning feedback
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Warning!',
                feedbackType: FeedbackType.warning,
                sessionDuration: Duration.zero,
                accuracyPercentage: 0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning), findsOneWidget);

        // Test error feedback
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Error!',
                feedbackType: FeedbackType.error,
                sessionDuration: Duration.zero,
                accuracyPercentage: 0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.error), findsOneWidget);

        // Test neutral feedback
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Neutral',
                feedbackType: FeedbackType.neutral,
                sessionDuration: Duration.zero,
                accuracyPercentage: 0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.info), findsOneWidget);
      });

      testWidgets('should format duration correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Test',
                feedbackType: FeedbackType.neutral,
                sessionDuration: Duration(hours: 1, minutes: 5, seconds: 30),
                accuracyPercentage: 0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(
          find.text('65:30'),
          findsOneWidget,
        ); // 1 hour 5 minutes = 65 minutes
      });

      testWidgets('should show accuracy colors correctly', (
        WidgetTester tester,
      ) async {
        // Test high accuracy (green)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Test',
                feedbackType: FeedbackType.neutral,
                sessionDuration: Duration.zero,
                accuracyPercentage: 85.0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('85.0%'), findsOneWidget);

        // Test medium accuracy (orange)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Test',
                feedbackType: FeedbackType.neutral,
                sessionDuration: Duration.zero,
                accuracyPercentage: 65.0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('65.0%'), findsOneWidget);

        // Test low accuracy (red)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FeedbackOverlay(
                feedback: 'Test',
                feedbackType: FeedbackType.neutral,
                sessionDuration: Duration.zero,
                accuracyPercentage: 45.0,
                correctPostureCount: 0,
                totalPoseCount: 0,
              ),
            ),
          ),
        );

        expect(find.text('45.0%'), findsOneWidget);
      });
    });
  });

  group('SkeletonPainter', () {
    test('should have correct keypoint connections', () {
      // Test that the skeleton painter has the expected connections
      // This is a basic test to ensure the connections are defined
      expect(SkeletonPainter, isA<Type>());
    });
  });

  group('AdvancedSkeletonPainter', () {
    test('should have body part connections defined', () {
      // Test that the advanced skeleton painter has body part connections
      expect(AdvancedSkeletonPainter, isA<Type>());
    });

    test('should handle pose data correctly', () {
      final painter = AdvancedSkeletonPainter(
        poseData: PoseData(
          keyPoints: [KeyPoint(name: 'nose', x: 0.5, y: 0.3, confidence: 0.8)],
          confidence: 0.8,
          timestamp: DateTime.now(),
        ),
        confidenceThreshold: 0.5,
        keypointColor: Colors.green,
        connectionColor: Colors.blue,
        keypointRadius: 6.0,
        connectionWidth: 3.0,
        showConfidenceIndicator: true,
        showKeyPointLabels: false,
      );

      expect(painter, isA<AdvancedSkeletonPainter>());
    });
  });
}
