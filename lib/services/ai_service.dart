/// Abstract interface for AI services providing recipe generation and text summarization
abstract class AIService {
  /// Generates a recipe based on provided ingredients
  /// Returns a JSON string containing recipe data
  Future<String> generateRecipe(List<String> ingredients);

  /// Summarizes the provided text
  /// Returns a JSON string containing summary data
  Future<String> summarizeText(String text);

  /// Checks if the service is currently available
  bool get isAvailable;

  /// Disposes of any resources used by the service
  void dispose();
}

/// Exception thrown when AI service operations fail
class AIServiceException implements Exception {
  final String message;
  final String? technicalDetails;
  final bool isRetryable;

  const AIServiceException(
    this.message, {
    this.technicalDetails,
    this.isRetryable = false,
  });

  @override
  String toString() => 'AIServiceException: $message';
}
