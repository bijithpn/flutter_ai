import 'package:hive/hive.dart';

part 'note_summary.g.dart';

@HiveType(typeId: 3)
class NoteSummary extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String originalText;

  @HiveField(2)
  final String summary;

  @HiveField(3)
  final List<String> keyPoints;

  @HiveField(4)
  final DateTime createdAt;

  NoteSummary({
    required this.id,
    required this.originalText,
    required this.summary,
    required this.keyPoints,
    required this.createdAt,
  });

  // JSON serialization
  factory NoteSummary.fromJson(Map<String, dynamic> json) {
    return NoteSummary(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      summary: json['summary'] as String,
      keyPoints: List<String>.from(json['keyPoints'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalText': originalText,
      'summary': summary,
      'keyPoints': keyPoints,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Utility methods
  NoteSummary copyWith({
    String? id,
    String? originalText,
    String? summary,
    List<String>? keyPoints,
    DateTime? createdAt,
  }) {
    return NoteSummary(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get word count of original text
  int get originalWordCount {
    final trimmed = originalText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  // Get word count of summary
  int get summaryWordCount {
    final trimmed = summary.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  // Calculate compression ratio
  double get compressionRatio {
    if (originalWordCount == 0) return 0.0;
    return summaryWordCount / originalWordCount;
  }

  // Check if summary is significantly shorter than original
  bool get isEffectiveSummary {
    return compressionRatio < 0.7 && summaryWordCount > 10;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteSummary &&
        other.id == id &&
        other.originalText == originalText &&
        other.summary == summary &&
        other.keyPoints.length == keyPoints.length &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      originalText,
      summary,
      keyPoints,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'NoteSummary(id: $id, originalWords: $originalWordCount, summaryWords: $summaryWordCount)';
  }
}