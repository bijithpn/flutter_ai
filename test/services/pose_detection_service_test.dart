import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/camera_permission_service.dart';

void main() {
  group('Pose Detection Models', () {
    group('KeyPoint', () {
      test('should create KeyPoint with correct properties', () {
        final keyPoint = KeyPoint(
          name: 'nose',
          x: 0.5,
          y: 0.3,
          confidence: 0.8,
        );

        expect(keyPoint.name, equals('nose'));
        expect(keyPoint.x, equals(0.5));
        expect(keyPoint.y, equals(0.3));
        expect(keyPoint.confidence, equals(0.8));
      });

      test('should validate keypoint confidence correctly', () {
        final validKeyPoint = KeyPoint(
          name: 'nose',
          x: 0.5,
          y: 0.3,
          confidence: 0.8,
        );

        final invalidKeyPoint = KeyPoint(
          name: 'nose',
          x: 0.5,
          y: 0.3,
          confidence: 0.3,
        );

        expect(validKeyPoint.isValid(), isTrue);
        expect(invalidKeyPoint.isValid(), isFalse);
        expect(invalidKeyPoint.isValid(threshold: 0.2), isTrue);
      });
    });

    group('PoseData', () {
      test('should create PoseData with keypoints', () {
        final keyPoints = [
          KeyPoint(name: 'nose', x: 0.5, y: 0.3, confidence: 0.8),
          KeyPoint(name: 'left_eye', x: 0.4, y: 0.2, confidence: 0.7),
        ];

        final poseData = PoseData(
          keyPoints: keyPoints,
          confidence: 0.75,
          timestamp: DateTime.now(),
        );

        expect(poseData.keyPoints.length, equals(2));
        expect(poseData.confidence, equals(0.75));
        expect(poseData.isReliable(), isTrue);
      });

      test('should filter valid keypoints correctly', () {
        final keyPoints = [
          KeyPoint(name: 'nose', x: 0.5, y: 0.3, confidence: 0.8),
          KeyPoint(name: 'left_eye', x: 0.4, y: 0.2, confidence: 0.3),
          KeyPoint(name: 'right_eye', x: 0.6, y: 0.2, confidence: 0.9),
        ];

        final poseData = PoseData(
          keyPoints: keyPoints,
          confidence: 0.75,
          timestamp: DateTime.now(),
        );

        final validKeyPoints = poseData.getValidKeyPoints();
        expect(validKeyPoints.length, equals(2));
        expect(validKeyPoints[0].name, equals('nose'));
        expect(validKeyPoints[1].name, equals('right_eye'));
      });

      test('should find keypoint by name', () {
        final keyPoints = [
          KeyPoint(name: 'nose', x: 0.5, y: 0.3, confidence: 0.8),
          KeyPoint(name: 'left_eye', x: 0.4, y: 0.2, confidence: 0.7),
        ];

        final poseData = PoseData(
          keyPoints: keyPoints,
          confidence: 0.75,
          timestamp: DateTime.now(),
        );

        final noseKeyPoint = poseData.getKeyPoint('nose');
        expect(noseKeyPoint, isNotNull);
        expect(noseKeyPoint!.name, equals('nose'));

        final nonExistentKeyPoint = poseData.getKeyPoint('non_existent');
        expect(nonExistentKeyPoint, isNull);
      });
    });
  });

  group('Camera Permission Status', () {
    test('should have correct permission status enum values', () {
      expect(CameraPermissionStatus.values.length, equals(3));
      expect(
        CameraPermissionStatus.values,
        contains(CameraPermissionStatus.granted),
      );
      expect(
        CameraPermissionStatus.values,
        contains(CameraPermissionStatus.denied),
      );
      expect(
        CameraPermissionStatus.values,
        contains(CameraPermissionStatus.permanentlyDenied),
      );
    });
  });
}
