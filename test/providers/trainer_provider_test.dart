import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_ai_mvp/providers/trainer_provider.dart';
import 'package:flutter_ai_mvp/services/services.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'dart:async';

import 'trainer_provider_test.mocks.dart';

@GenerateMocks([PoseDetectionService, StorageRepository])
void main() {
  group('TrainerProvider', () {
    late MockPoseDetectionService mockPoseService;
    late MockStorageRepository<WorkoutSession> mockWorkoutRepository;
    late TrainerProvider trainerProvider;
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

      trainerProvider = TrainerProvider(
        poseDetectionService: mockPoseService,
        workoutRepository: mockWorkoutRepository,
      );
    });

    tearDown(() {
      poseStreamController.close();
      trainerProvider.dispose();
    });

    group('Initialization', () {
      test('should start in idle state', () {
        expect(trainerProvider.state, equals(TrainerState.idle));
        expect(trainerProvider.errorMessage, isNull);
        expect(trainerProvider.currentPose, isNull);
        expect(trainerProvider.selectedExercise, equals('general'));
      });

      test('should load workout history on creation', () async {
        final mockSessions = [
          WorkoutSession(
            id: '1',
            exerciseType: 'pushup',
            duration: const Duration(minutes: 5),
            poseHistory: [],
            correctPostureCount: 10,
            startTime: DateTime.now(),
          ),
        ];

        when(
          mockWorkoutRepository.loadAll(),
        ).thenAnswer((_) async => mockSessions);

        final provider = TrainerProvider(
          poseDetectionService: mockPoseService,
          workoutRepository: mockWorkoutRepository,
        );

        // Wait for async initialization
        await Future.delayed(const Duration(milliseconds: 100));

        expect(provider.workoutHistory.length, equals(1));
        expect(provider.workoutHistory.first.exerciseType, equals('pushup'));

        provider.dispose();
      });
    });

    group('Exercise Selection', () {
      test('should update selected exercise', () {
        expect(trainerProvider.selectedExercise, equals('general'));

        trainerProvider.setSelectedExercise('pushup');
        expect(trainerProvider.selectedExercise, equals('pushup'));

        trainerProvider.setSelectedExercise('squat');
        expect(trainerProvider.selectedExercise, equals('squat'));
      });

      test('should notify listeners when exercise changes', () {
        bool notified = false;
        trainerProvider.addListener(() {
          notified = true;
        });

        trainerProvider.setSelectedExercise('plank');
        expect(notified, isTrue);
      });

      test('should not notify if same exercise is selected', () {
        bool notified = false;
        trainerProvider.addListener(() {
          notified = true;
        });

        trainerProvider.setSelectedExercise('general'); // Same as default
        expect(notified, isFalse);
      });
    });

    group('Pose Detection', () {
      test('should initialize pose detection service', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});

        await trainerProvider.initialize();

        verify(mockPoseService.initialize()).called(1);
        expect(trainerProvider.state, equals(TrainerState.ready));
      });

      test('should handle initialization errors', () async {
        when(mockPoseService.initialize()).thenThrow(Exception('Camera error'));

        await trainerProvider.initialize();

        expect(trainerProvider.state, equals(TrainerState.error));
        expect(trainerProvider.errorMessage, contains('Camera error'));
      });

      test('should start detection and listen to pose stream', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        verify(mockPoseService.startDetection()).called(1);
        expect(trainerProvider.state, equals(TrainerState.detecting));
      });

      test('should process pose data from stream', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        final poseData = PoseData(
          keyPoints: _createMockKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(poseData);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.currentPose, equals(poseData));
        expect(trainerProvider.totalPoseCount, equals(1));
      });

      test('should stop detection and end session', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});
        when(mockPoseService.stopDetection()).thenAnswer((_) async {});
        when(mockWorkoutRepository.save(any, any)).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();
        await trainerProvider.stopDetection();

        verify(mockPoseService.stopDetection()).called(1);
        expect(trainerProvider.state, equals(TrainerState.ready));
      });
    });

    group('Pose Analysis', () {
      test('should analyze general pose correctly', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        // High confidence pose with many keypoints
        final goodPose = PoseData(
          keyPoints: _createMockKeyPoints(confidence: 0.9),
          confidence: 0.9,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(goodPose);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.correctPostureCount, equals(1));
        expect(trainerProvider.feedbackType, equals(FeedbackType.positive));
      });

      test('should provide pushup-specific feedback', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        trainerProvider.setSelectedExercise('pushup');
        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        final pushupPose = PoseData(
          keyPoints: _createPushupKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(pushupPose);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.currentFeedback, contains('push-up'));
      });

      test('should provide squat-specific feedback', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        trainerProvider.setSelectedExercise('squat');
        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        final squatPose = PoseData(
          keyPoints: _createSquatKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(squatPose);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.currentFeedback, contains('squat'));
      });

      test('should provide plank-specific feedback', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        trainerProvider.setSelectedExercise('plank');
        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        final plankPose = PoseData(
          keyPoints: _createPlankKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(plankPose);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.currentFeedback, contains('plank'));
      });

      test('should handle low confidence poses', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        final lowConfidencePose = PoseData(
          keyPoints: _createMockKeyPoints(confidence: 0.3),
          confidence: 0.3,
          timestamp: DateTime.now(),
        );

        poseStreamController.add(lowConfidencePose);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.feedbackType, equals(FeedbackType.warning));
        expect(trainerProvider.currentFeedback, contains('confidence low'));
      });
    });

    group('Session Management', () {
      test('should track session duration', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        expect(trainerProvider.sessionDuration, equals(Duration.zero));

        // Wait a bit and check if duration is being tracked
        await Future.delayed(const Duration(milliseconds: 100));
        expect(trainerProvider.sessionDuration.inMilliseconds, greaterThan(0));
      });

      test('should calculate accuracy percentage', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        // Add some poses
        for (int i = 0; i < 10; i++) {
          final pose = PoseData(
            keyPoints: _createMockKeyPoints(confidence: i < 7 ? 0.9 : 0.3),
            confidence: i < 7 ? 0.9 : 0.3,
            timestamp: DateTime.now(),
          );
          poseStreamController.add(pose);
          await Future.delayed(const Duration(milliseconds: 10));
        }

        expect(trainerProvider.totalPoseCount, equals(10));
        expect(trainerProvider.correctPostureCount, equals(7));
        expect(trainerProvider.accuracyPercentage, equals(70.0));
      });

      test('should save workout session on stop', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});
        when(mockPoseService.stopDetection()).thenAnswer((_) async {});
        when(mockWorkoutRepository.save(any, any)).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        // Add some poses
        final pose = PoseData(
          keyPoints: _createMockKeyPoints(),
          confidence: 0.8,
          timestamp: DateTime.now(),
        );
        poseStreamController.add(pose);
        await Future.delayed(const Duration(milliseconds: 50));

        await trainerProvider.stopDetection();

        verify(mockWorkoutRepository.save(any, any)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle pose stream errors', () async {
        when(mockPoseService.initialize()).thenAnswer((_) async {});
        when(mockPoseService.startDetection()).thenAnswer((_) async {});

        await trainerProvider.initialize();
        await trainerProvider.startDetection();

        poseStreamController.addError(Exception('Pose detection failed'));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(trainerProvider.state, equals(TrainerState.error));
        expect(trainerProvider.errorMessage, contains('Pose detection error'));
      });

      test('should clear errors', () {
        trainerProvider.setSelectedExercise(
          'pushup',
        ); // Set state to non-error first
        // Simulate error state
        when(mockPoseService.initialize()).thenThrow(Exception('Test error'));
        trainerProvider.initialize();

        expect(trainerProvider.hasError, isTrue);

        trainerProvider.clearError();
        expect(trainerProvider.hasError, isFalse);
        expect(trainerProvider.errorMessage, isNull);
      });
    });
  });
}

// Helper functions to create mock keypoints
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
