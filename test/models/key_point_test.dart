import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/key_point.dart';

void main() {
  group('KeyPoint Model Tests', () {
    late KeyPoint testKeyPoint;

    setUp(() {
      testKeyPoint = KeyPoint(
        name: 'nose',
        x: 100.5,
        y: 200.7,
        confidence: 0.85,
      );
    });

    test('should create KeyPoint with all required fields', () {
      expect(testKeyPoint.name, equals('nose'));
      expect(testKeyPoint.x, equals(100.5));
      expect(testKeyPoint.y, equals(200.7));
      expect(testKeyPoint.confidence, equals(0.85));
    });

    test('should serialize to JSON correctly', () {
      final json = testKeyPoint.toJson();

      expect(json['name'], equals('nose'));
      expect(json['x'], equals(100.5));
      expect(json['y'], equals(200.7));
      expect(json['confidence'], equals(0.85));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'name': 'nose',
        'x': 100.5,
        'y': 200.7,
        'confidence': 0.85,
      };

      final keyPoint = KeyPoint.fromJson(json);

      expect(keyPoint.name, equals('nose'));
      expect(keyPoint.x, equals(100.5));
      expect(keyPoint.y, equals(200.7));
      expect(keyPoint.confidence, equals(0.85));
    });

    test('should handle integer coordinates in JSON', () {
      final json = {
        'name': 'nose',
        'x': 100,
        'y': 200,
        'confidence': 0.85,
      };

      final keyPoint = KeyPoint.fromJson(json);

      expect(keyPoint.x, equals(100.0));
      expect(keyPoint.y, equals(200.0));
    });

    test('should create copy with modified fields', () {
      final modifiedKeyPoint = testKeyPoint.copyWith(
        name: 'left_eye',
        confidence: 0.95,
      );

      expect(modifiedKeyPoint.name, equals('left_eye'));
      expect(modifiedKeyPoint.x, equals(testKeyPoint.x));
      expect(modifiedKeyPoint.y, equals(testKeyPoint.y));
      expect(modifiedKeyPoint.confidence, equals(0.95));
    });

    test('should validate key point with default threshold', () {
      final validKeyPoint = KeyPoint(
        name: 'nose',
        x: 100.0,
        y: 200.0,
        confidence: 0.6,
      );

      final invalidKeyPoint = KeyPoint(
        name: 'nose',
        x: 100.0,
        y: 200.0,
        confidence: 0.4,
      );

      expect(validKeyPoint.isValid(), isTrue);
      expect(invalidKeyPoint.isValid(), isFalse);
    });

    test('should validate key point with custom threshold', () {
      final keyPoint = KeyPoint(
        name: 'nose',
        x: 100.0,
        y: 200.0,
        confidence: 0.7,
      );

      expect(keyPoint.isValid(threshold: 0.6), isTrue);
      expect(keyPoint.isValid(threshold: 0.8), isFalse);
    });

    test('should implement equality correctly', () {
      final keyPoint1 = KeyPoint(
        name: 'nose',
        x: 100.0,
        y: 200.0,
        confidence: 0.85,
      );

      final keyPoint2 = KeyPoint(
        name: 'nose',
        x: 100.0,
        y: 200.0,
        confidence: 0.85,
      );

      final keyPoint3 = keyPoint1.copyWith(name: 'left_eye');

      expect(keyPoint1, equals(keyPoint2));
      expect(keyPoint1, isNot(equals(keyPoint3)));
      expect(keyPoint1.hashCode, equals(keyPoint2.hashCode));
    });

    test('should have proper toString implementation', () {
      final string = testKeyPoint.toString();
      expect(string, contains('nose'));
      expect(string, contains('100.5'));
      expect(string, contains('200.7'));
      expect(string, contains('0.85'));
    });

    test('should validate JSON round-trip', () {
      final json = testKeyPoint.toJson();
      final deserializedKeyPoint = KeyPoint.fromJson(json);
      final reserializedJson = deserializedKeyPoint.toJson();

      expect(json, equals(reserializedJson));
      expect(testKeyPoint, equals(deserializedKeyPoint));
    });

    test('should handle edge case confidence values', () {
      final zeroConfidence = KeyPoint(
        name: 'test',
        x: 0.0,
        y: 0.0,
        confidence: 0.0,
      );

      final maxConfidence = KeyPoint(
        name: 'test',
        x: 0.0,
        y: 0.0,
        confidence: 1.0,
      );

      expect(zeroConfidence.isValid(), isFalse);
      expect(maxConfidence.isValid(), isTrue);
    });
  });
}