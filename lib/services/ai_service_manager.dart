import 'ai_service.dart';
import 'openai_service.dart';
import 'connectivity_service.dart';

/// Manages AI services and handles online/offline fallback
class AIServiceManager {
  static final AIServiceManager _instance = AIServiceManager._internal();
  factory AIServiceManager() => _instance;
  AIServiceManager._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  late final OpenAIService _openAIService;
  AIService? _offlineService; // Will be implemented in future tasks

  bool _isInitialized = false;

  /// Initialize the AI service manager
  Future<void> initialize({String? openAIApiKey}) async {
    if (_isInitialized) return;

    // Initialize connectivity monitoring
    await _connectivityService.initialize();

    // Initialize OpenAI service
    _openAIService = OpenAIService();
    if (openAIApiKey != null) {
      await _openAIService.initialize(openAIApiKey);
    } else {
      await _openAIService.loadApiKey();
    }

    _isInitialized = true;
  }

  /// Set the offline AI service (for future implementation)
  void setOfflineService(AIService offlineService) {
    _offlineService = offlineService;
  }

  /// Get the appropriate AI service based on connectivity and availability
  AIService get currentService {
    if (!_isInitialized) {
      throw const AIServiceException(
        'AI Service Manager not initialized. Call initialize() first.',
        isRetryable: false,
      );
    }

    // Prefer online service if available and connected
    if (_connectivityService.isOnline && _openAIService.isAvailable) {
      return _openAIService;
    }

    // Fallback to offline service if available
    if (_offlineService != null && _offlineService!.isAvailable) {
      return _offlineService!;
    }

    // No service available
    throw const AIServiceException(
      'No AI service available. Please check your internet connection or API key.',
      isRetryable: true,
    );
  }

  /// Generate recipe using the best available service
  Future<String> generateRecipe(List<String> ingredients) async {
    try {
      return await currentService.generateRecipe(ingredients);
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException(
        'Failed to generate recipe: ${e.toString()}',
        isRetryable: true,
      );
    }
  }

  /// Summarize text using the best available service
  Future<String> summarizeText(String text) async {
    try {
      return await currentService.summarizeText(text);
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException(
        'Failed to summarize text: ${e.toString()}',
        isRetryable: true,
      );
    }
  }

  /// Check if any AI service is currently available
  bool get isServiceAvailable {
    if (!_isInitialized) return false;

    return (_connectivityService.isOnline && _openAIService.isAvailable) ||
        (_offlineService != null && _offlineService!.isAvailable);
  }

  /// Get connectivity status
  bool get isOnline => _connectivityService.isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream =>
      _connectivityService.connectivityStream;

  /// Update OpenAI API key
  Future<void> updateOpenAIApiKey(String apiKey) async {
    if (_isInitialized) {
      await _openAIService.initialize(apiKey);
    }
  }

  /// Dispose of all services
  void dispose() {
    if (_isInitialized) {
      _openAIService.dispose();
      _offlineService?.dispose();
      _connectivityService.dispose();
    }
  }
}
