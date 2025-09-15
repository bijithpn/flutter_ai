import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/pose_data.dart';
import 'package:flutter_ai_mvp/models/key_point.dart';

void main() {
  group('PoseData Model Tests', () {
    late PoseData testPoseData;
    late DateTime testTimestamp;
    late List<KeyPoint> testKeyPoints;

    setUp(() {
      testTimestamp = DateTime(2024, 1, 15, 12, 0, 0);
      testKeyPoints = [
        KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.9),
        KeyPoint(name: 'left_eye', x: 90.0, y: 190.0, confidence: 0.8),
        KeyPoint(name: 'right_eye', x: 110.0, y: 190.0, confidence: 0.3), // Low confidence
      ];
      
      testPoseData = PoseData(
        keyPoints: testKeyPoints,
        confidence: 0.85,
        timestamp: testTimestamp,
      );
    });

    test('should create PoseData with all required fields', () {
      expect(testPoseData.keyPoints, hasLength(3));
      expect(testPoseData.confidence, equals(0.85));
      expect(testPoseData.timestamp, equals(testTimestamp));
    });

    test('should serialize to JSON correctly', () {
      final json = testPoseData.toJson();

      expect(json['keyPoints'], hasLength(3));
      expect(json['confidence'], equals(0.85));
      expect(json['timestamp'], equals(testTimestamp.toIso8601String()));
      
      final firstKeyPoint = json['keyPoints'][0];
      expect(firstKeyPoint['name'], equals('nose'));
      expect(firstKeyPoint['x'], equals(100.0));
      expect(firstKeyPoint['y'], equals(200.0));
      expect(firstKeyPoint['confidence'], equals(0.9));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'keyPoints': [
          {'name': 'nose', 'x': 100.0, 'y': 200.0, 'confidence': 0.9},
          {'name': 'left_eye', 'x': 90.0, 'y': 190.0, 'confidence': 0.8},
        ],
        'confidence': 0.85,
        'timestamp': testTimestamp.toIso8601String(),
      };

      final poseData = PoseData.fromJson(json);

      expect(poseData.keyPoints, hasLength(2));
      expect(poseData.confidence, equals(0.85));
      expect(poseData.timestamp, equals(testTimestamp));
      expect(poseData.keyPoints[0].name, equals('nose'));
    });

    test('should create copy with modified fields', () {
      final newTimestamp = DateTime.now();
      final modifiedPoseData = testPoseData.copyWith(
        confidence: 0.95,
        timestamp: newTimestamp,
      );

      expect(modifiedPoseData.keyPoints, equals(testPoseData.keyPoints));
      expect(modifiedPoseData.confidence, equals(0.95));
      expect(modifiedPoseData.timestamp, equals(newTimestamp));
    });

    test('should filter valid key points with default threshold', () {
      final validKeyPoints = testPoseData.getValidKeyPoints();
      
      expect(validKeyPoints, hasLength(2)); // nose and left_eye have confidence >= 0.5
      expect(validKeyPoints[0].name, equals('nose'));
      expect(validKeyPoints[1].name, equals('left_eye'));
    });

    test('should filter valid key points with custom threshold', () {
      final validKeyPoints = testPoseData.getValidKeyPoints(threshold: 0.85);
      
      expect(validKeyPoints, hasLength(1)); // Only nose has confidence >= 0.85
      expect(validKeyPoints[0].name, equals('nose'));
    });

    test('should check if pose is reliable with default threshold', () {
      final reliablePose = PoseData(
        keyPoints: testKeyPoints,
        confidence: 0.8,
        timestamp: testTimestamp,
      );

      final unreliablePose = PoseData(
        keyPoints: testKeyPoints,
        confidence: 0.6,
        timestamp: testTimestamp,
      );

      expect(reliablePose.isReliable(), isTrue);
      expect(unreliablePose.isReliable(), isFalse);
    });

    test('should check if pose is reliable with custom threshold', () {
      expect(testPoseData.isReliable(threshold: 0.8), isTrue);
      expect(testPoseData.isReliable(threshold: 0.9), isFalse);
    });

    test('should get key point by name', () {
      final noseKeyPoint = testPoseData.getKeyPoint('nose');
      final nonExistentKeyPoint = testPoseData.getKeyPoint('shoulder');

      expect(noseKeyPoint, isNotNull);
      expect(noseKeyPoint!.name, equals('nose'));
      expect(noseKeyPoint.confidence, equals(0.9));
      expect(nonExistentKeyPoint, isNull);
    });

    test('should implement equality correctly', () {
      final poseData1 = PoseData(
        keyPoints: [
          KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.9),
        ],
        confidence: 0.85,
        timestamp: testTimestamp,
      );

      final poseData2 = PoseData(
        keyPoints: [
          KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.9),
        ],
        confidence: 0.85,
        timestamp: testTimestamp,
      );

      final poseData3 = poseData1.copyWith(confidence: 0.95);

      expect(poseData1, equals(poseData2));
      expect(poseData1, isNot(equals(poseData3)));
    });

    test('should have proper toString implementation', () {
      final string = testPoseData.toString();
      expect(string, contains('3')); // keyPoints length
      expect(string, contains('0.85')); // confidence
      expect(string, contains(testTimestamp.toString()));
    });

    test('should validate JSON round-trip', () {
      final json = testPoseData.toJson();
      final deserializedPoseData = PoseData.fromJson(json);
      final reserializedJson = deserializedPoseData.toJson();

      expect(json, equals(reserializedJson));
      expect(testPoseData, equals(deserializedPoseData));
    });

    test('should handle empty key points list', () {
      final emptyPoseData = PoseData(
        keyPoints: [],
        confidence: 0.5,
        timestamp: testTimestamp,
      );

      expect(emptyPoseData.getValidKeyPoints(), isEmpty);
      expect(emptyPoseData.getKeyPoint('nose'), isNull);
    });
  });
}