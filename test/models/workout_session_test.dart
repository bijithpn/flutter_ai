import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/workout_session.dart';
import 'package:flutter_ai_mvp/models/pose_data.dart';
import 'package:flutter_ai_mvp/models/key_point.dart';

void main() {
  group('WorkoutSession Model Tests', () {
    late WorkoutSession testWorkoutSession;
    late DateTime testStartTime;
    late List<PoseData> testPoseHistory;

    setUp(() {
      testStartTime = DateTime(2024, 1, 15, 12, 0, 0);
      
      testPoseHistory = [
        PoseData(
          keyPoints: [KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.9)],
          confidence: 0.8,
          timestamp: testStartTime,
        ),
        PoseData(
          keyPoints: [KeyPoint(name: 'nose', x: 105.0, y: 205.0, confidence: 0.85)],
          confidence: 0.75,
          timestamp: testStartTime.add(const Duration(seconds: 1)),
        ),
        PoseData(
          keyPoints: [KeyPoint(name: 'nose', x: 110.0, y: 210.0, confidence: 0.7)],
          confidence: 0.6,
          timestamp: testStartTime.add(const Duration(seconds: 2)),
        ),
      ];
      
      testWorkoutSession = WorkoutSession(
        id: 'workout_1',
        exerciseType: 'pushup',
        duration: const Duration(minutes: 5),
        poseHistory: testPoseHistory,
        correctPostureCount: 2,
        startTime: testStartTime,
      );
    });

    test('should create WorkoutSession with all required fields', () {
      expect(testWorkoutSession.id, equals('workout_1'));
      expect(testWorkoutSession.exerciseType, equals('pushup'));
      expect(testWorkoutSession.duration, equals(const Duration(minutes: 5)));
      expect(testWorkoutSession.poseHistory, hasLength(3));
      expect(testWorkoutSession.correctPostureCount, equals(2));
      expect(testWorkoutSession.startTime, equals(testStartTime));
    });

    test('should serialize to JSON correctly', () {
      final json = testWorkoutSession.toJson();

      expect(json['id'], equals('workout_1'));
      expect(json['exerciseType'], equals('pushup'));
      expect(json['duration'], equals(300000)); // 5 minutes in milliseconds
      expect(json['poseHistory'], hasLength(3));
      expect(json['correctPostureCount'], equals(2));
      expect(json['startTime'], equals(testStartTime.toIso8601String()));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'workout_1',
        'exerciseType': 'pushup',
        'duration': 300000,
        'poseHistory': [
          {
            'keyPoints': [
              {'name': 'nose', 'x': 100.0, 'y': 200.0, 'confidence': 0.9}
            ],
            'confidence': 0.8,
            'timestamp': testStartTime.toIso8601String(),
          }
        ],
        'correctPostureCount': 2,
        'startTime': testStartTime.toIso8601String(),
      };

      final workoutSession = WorkoutSession.fromJson(json);

      expect(workoutSession.id, equals('workout_1'));
      expect(workoutSession.exerciseType, equals('pushup'));
      expect(workoutSession.duration, equals(const Duration(minutes: 5)));
      expect(workoutSession.poseHistory, hasLength(1));
      expect(workoutSession.correctPostureCount, equals(2));
      expect(workoutSession.startTime, equals(testStartTime));
    });

    test('should create copy with modified fields', () {
      final modifiedWorkoutSession = testWorkoutSession.copyWith(
        exerciseType: 'squat',
        correctPostureCount: 5,
      );

      expect(modifiedWorkoutSession.id, equals(testWorkoutSession.id));
      expect(modifiedWorkoutSession.exerciseType, equals('squat'));
      expect(modifiedWorkoutSession.duration, equals(testWorkoutSession.duration));
      expect(modifiedWorkoutSession.correctPostureCount, equals(5));
      expect(modifiedWorkoutSession.startTime, equals(testWorkoutSession.startTime));
    });

    test('should calculate end time correctly', () {
      final endTime = testWorkoutSession.endTime;
      final expectedEndTime = testStartTime.add(const Duration(minutes: 5));
      
      expect(endTime, equals(expectedEndTime));
    });

    test('should calculate accuracy percentage correctly', () {
      final accuracy = testWorkoutSession.accuracyPercentage;
      
      expect(accuracy, closeTo(66.67, 0.01)); // 2/3 * 100 = 66.67%
    });

    test('should handle zero poses in accuracy calculation', () {
      final emptyWorkoutSession = testWorkoutSession.copyWith(
        poseHistory: [],
        correctPostureCount: 0,
      );
      
      expect(emptyWorkoutSession.accuracyPercentage, equals(0.0));
    });

    test('should calculate average confidence correctly', () {
      final avgConfidence = testWorkoutSession.averageConfidence;
      
      expect(avgConfidence, closeTo(0.717, 0.001)); // (0.8 + 0.75 + 0.6) / 3
    });

    test('should handle zero poses in average confidence calculation', () {
      final emptyWorkoutSession = testWorkoutSession.copyWith(poseHistory: []);
      
      expect(emptyWorkoutSession.averageConfidence, equals(0.0));
    });

    test('should determine if session is successful', () {
      final successfulSession = WorkoutSession(
        id: 'success',
        exerciseType: 'pushup',
        duration: const Duration(minutes: 2),
        poseHistory: List.generate(10, (i) => PoseData(
          keyPoints: [KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.9)],
          confidence: 0.8,
          timestamp: testStartTime.add(Duration(seconds: i)),
        )),
        correctPostureCount: 8, // 80% accuracy
        startTime: testStartTime,
      );

      final unsuccessfulSession = testWorkoutSession.copyWith(
        duration: const Duration(seconds: 30), // Too short
      );

      expect(successfulSession.isSuccessful, isTrue);
      expect(unsuccessfulSession.isSuccessful, isFalse);
    });

    test('should filter good form poses', () {
      final goodFormPoses = testWorkoutSession.goodFormPoses;
      
      expect(goodFormPoses, hasLength(2)); // First two poses have confidence >= 0.7
    });

    test('should estimate calories burned for different exercises', () {
      final pushupSession = testWorkoutSession;
      final squatSession = testWorkoutSession.copyWith(exerciseType: 'squat');
      final plankSession = testWorkoutSession.copyWith(exerciseType: 'plank');
      final jumpingJackSession = testWorkoutSession.copyWith(exerciseType: 'jumping_jack');
      final unknownSession = testWorkoutSession.copyWith(exerciseType: 'unknown_exercise');

      expect(pushupSession.estimatedCaloriesBurned, equals(40)); // 5 min * 8 cal/min
      expect(squatSession.estimatedCaloriesBurned, equals(30)); // 5 min * 6 cal/min
      expect(plankSession.estimatedCaloriesBurned, equals(20)); // 5 min * 4 cal/min
      expect(jumpingJackSession.estimatedCaloriesBurned, equals(50)); // 5 min * 10 cal/min
      expect(unknownSession.estimatedCaloriesBurned, equals(25)); // 5 min * 5 cal/min (general)
    });

    test('should implement equality correctly', () {
      final workoutSession1 = WorkoutSession(
        id: 'workout_1',
        exerciseType: 'pushup',
        duration: const Duration(minutes: 5),
        poseHistory: [],
        correctPostureCount: 2,
        startTime: testStartTime,
      );

      final workoutSession2 = WorkoutSession(
        id: 'workout_1',
        exerciseType: 'pushup',
        duration: const Duration(minutes: 5),
        poseHistory: [],
        correctPostureCount: 2,
        startTime: testStartTime,
      );

      final workoutSession3 = workoutSession1.copyWith(exerciseType: 'squat');

      expect(workoutSession1, equals(workoutSession2));
      expect(workoutSession1, isNot(equals(workoutSession3)));
    });

    test('should have proper toString implementation', () {
      final string = testWorkoutSession.toString();
      expect(string, contains('workout_1'));
      expect(string, contains('pushup'));
      expect(string, contains('5min'));
      expect(string, contains('66.7%'));
    });

    test('should validate JSON round-trip', () {
      final json = testWorkoutSession.toJson();
      final deserializedWorkoutSession = WorkoutSession.fromJson(json);
      final reserializedJson = deserializedWorkoutSession.toJson();

      expect(json, equals(reserializedJson));
      expect(testWorkoutSession, equals(deserializedWorkoutSession));
    });

    test('should handle case-insensitive exercise types in calorie calculation', () {
      final upperCaseSession = testWorkoutSession.copyWith(exerciseType: 'PUSHUP');
      final mixedCaseSession = testWorkoutSession.copyWith(exerciseType: 'PushUp');

      expect(upperCaseSession.estimatedCaloriesBurned, equals(40));
      expect(mixedCaseSession.estimatedCaloriesBurned, equals(40));
    });
  });
}