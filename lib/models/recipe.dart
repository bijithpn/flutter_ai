import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<String> ingredients;

  @HiveField(3)
  final List<String> steps;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final int cookingTime;

  @HiveField(6)
  final String difficulty;

  @HiveField(7)
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.imageUrl,
    required this.cookingTime,
    required this.difficulty,
    required this.createdAt,
  });

  // JSON serialization
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      steps: List<String>.from(json['steps'] as List),
      imageUrl: json['imageUrl'] as String?,
      cookingTime: json['cookingTime'] as int,
      difficulty: json['difficulty'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Utility methods
  Recipe copyWith({
    String? id,
    String? title,
    List<String>? ingredients,
    List<String>? steps,
    String? imageUrl,
    int? cookingTime,
    String? difficulty,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      imageUrl: imageUrl ?? this.imageUrl,
      cookingTime: cookingTime ?? this.cookingTime,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.id == id &&
        other.title == title &&
        other.ingredients.length == ingredients.length &&
        other.steps.length == steps.length &&
        other.imageUrl == imageUrl &&
        other.cookingTime == cookingTime &&
        other.difficulty == difficulty &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      ingredients,
      steps,
      imageUrl,
      cookingTime,
      difficulty,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, cookingTime: $cookingTime, difficulty: $difficulty)';
  }
}