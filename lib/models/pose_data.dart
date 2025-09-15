import 'package:hive/hive.dart';
import 'key_point.dart';

part 'pose_data.g.dart';

@HiveType(typeId: 2)
class PoseData extends HiveObject {
  @HiveField(0)
  final List<KeyPoint> keyPoints;

  @HiveField(1)
  final double confidence;

  @HiveField(2)
  final DateTime timestamp;

  PoseData({
    required this.keyPoints,
    required this.confidence,
    required this.timestamp,
  });

  // JSON serialization
  factory PoseData.fromJson(Map<String, dynamic> json) {
    return PoseData(
      keyPoints: (json['keyPoints'] as List)
          .map((e) => KeyPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyPoints': keyPoints.map((e) => e.toJson()).toList(),
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Utility methods
  PoseData copyWith({
    List<KeyPoint>? keyPoints,
    double? confidence,
    DateTime? timestamp,
  }) {
    return PoseData(
      keyPoints: keyPoints ?? this.keyPoints,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Get valid key points above confidence threshold
  List<KeyPoint> getValidKeyPoints({double threshold = 0.5}) {
    return keyPoints.where((kp) => kp.isValid(threshold: threshold)).toList();
  }

  // Check if pose detection is reliable
  bool isReliable({double threshold = 0.7}) {
    return confidence >= threshold;
  }

  // Get key point by name
  KeyPoint? getKeyPoint(String name) {
    try {
      return keyPoints.firstWhere((kp) => kp.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PoseData &&
        other.keyPoints.length == keyPoints.length &&
        other.confidence == confidence &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(keyPoints, confidence, timestamp);
  }

  @override
  String toString() {
    return 'PoseData(keyPoints: ${keyPoints.length}, confidence: $confidence, timestamp: $timestamp)';
  }
}