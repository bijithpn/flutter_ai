import 'package:hive/hive.dart';

part 'key_point.g.dart';

@HiveType(typeId: 1)
class KeyPoint extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double x;

  @HiveField(2)
  final double y;

  @HiveField(3)
  final double confidence;

  KeyPoint({
    required this.name,
    required this.x,
    required this.y,
    required this.confidence,
  });

  // JSON serialization
  factory KeyPoint.fromJson(Map<String, dynamic> json) {
    return KeyPoint(
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'x': x,
      'y': y,
      'confidence': confidence,
    };
  }

  // Utility methods
  KeyPoint copyWith({
    String? name,
    double? x,
    double? y,
    double? confidence,
  }) {
    return KeyPoint(
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      confidence: confidence ?? this.confidence,
    );
  }

  // Check if the key point is valid (confidence above threshold)
  bool isValid({double threshold = 0.5}) {
    return confidence >= threshold;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KeyPoint &&
        other.name == name &&
        other.x == x &&
        other.y == y &&
        other.confidence == confidence;
  }

  @override
  int get hashCode {
    return Object.hash(name, x, y, confidence);
  }

  @override
  String toString() {
    return 'KeyPoint(name: $name, x: $x, y: $y, confidence: $confidence)';
  }
}