import 'package:hive/hive.dart';
import 'pose_data.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 4)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseType;

  @HiveField(2)
  final Duration duration;

  @HiveField(3)
  final List<PoseData> poseHistory;

  @HiveField(4)
  final int correctPostureCount;

  @HiveField(5)
  final DateTime startTime;

  WorkoutSession({
    required this.id,
    required this.exerciseType,
    required this.duration,
    required this.poseHistory,
    required this.correctPostureCount,
    required this.startTime,
  });

  // JSON serialization
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      exerciseType: json['exerciseType'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      poseHistory: (json['poseHistory'] as List)
          .map((e) => PoseData.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctPostureCount: json['correctPostureCount'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseType': exerciseType,
      'duration': duration.inMilliseconds,
      'poseHistory': poseHistory.map((e) => e.toJson()).toList(),
      'correctPostureCount': correctPostureCount,
      'startTime': startTime.toIso8601String(),
    };
  }

  // Utility methods
  WorkoutSession copyWith({
    String? id,
    String? exerciseType,
    Duration? duration,
    List<PoseData>? poseHistory,
    int? correctPostureCount,
    DateTime? startTime,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      exerciseType: exerciseType ?? this.exerciseType,
      duration: duration ?? this.duration,
      poseHistory: poseHistory ?? this.poseHistory,
      correctPostureCount: correctPostureCount ?? this.correctPostureCount,
      startTime: startTime ?? this.startTime,
    );
  }

  // Calculate end time
  DateTime get endTime {
    return startTime.add(duration);
  }

  // Calculate accuracy percentage
  double get accuracyPercentage {
    if (poseHistory.isEmpty) return 0.0;
    return (correctPostureCount / poseHistory.length) * 100;
  }

  // Get average confidence across all poses
  double get averageConfidence {
    if (poseHistory.isEmpty) return 0.0;
    final totalConfidence = poseHistory
        .map((pose) => pose.confidence)
        .reduce((a, b) => a + b);
    return totalConfidence / poseHistory.length;
  }

  // Check if session was successful (good accuracy and duration)
  bool get isSuccessful {
    return accuracyPercentage >= 70.0 && 
           duration.inMinutes >= 1 && 
           averageConfidence >= 0.6;
  }

  // Get poses with good form (high confidence)
  List<PoseData> get goodFormPoses {
    return poseHistory.where((pose) => pose.isReliable()).toList();
  }

  // Calculate calories burned (rough estimate based on duration and exercise type)
  int get estimatedCaloriesBurned {
    const caloriesPerMinute = {
      'pushup': 8,
      'squat': 6,
      'plank': 4,
      'jumping_jack': 10,
      'general': 5,
    };
    
    final rate = caloriesPerMinute[exerciseType.toLowerCase()] ?? 
                 caloriesPerMinute['general']!;
    return (duration.inMinutes * rate).round();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession &&
        other.id == id &&
        other.exerciseType == exerciseType &&
        other.duration == duration &&
        other.poseHistory.length == poseHistory.length &&
        other.correctPostureCount == correctPostureCount &&
        other.startTime == startTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      exerciseType,
      duration,
      poseHistory,
      correctPostureCount,
      startTime,
    );
  }

  @override
  String toString() {
    return 'WorkoutSession(id: $id, exercise: $exerciseType, duration: ${duration.inMinutes}min, accuracy: ${accuracyPercentage.toStringAsFixed(1)}%)';
  }
}