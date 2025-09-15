import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ai_service.dart';

/// OpenAI API implementation of AIService
class OpenAIService implements AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _apiKeyStorageKey = 'openai_api_key';
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;
  String? _apiKey;

  OpenAIService({http.Client? httpClient, FlutterSecureStorage? secureStorage})
    : _httpClient = httpClient ?? http.Client(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  @override
  bool get isAvailable => _apiKey != null && _apiKey!.isNotEmpty;

  /// Initialize the service with API key
  Future<void> initialize(String apiKey) async {
    _apiKey = apiKey;
    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
  }

  /// Load API key from secure storage
  Future<void> loadApiKey() async {
    _apiKey = await _secureStorage.read(key: _apiKeyStorageKey);
  }

  @override
  Future<String> generateRecipe(List<String> ingredients) async {
    if (!isAvailable) {
      throw const AIServiceException(
        'OpenAI service not available. Please check your API key.',
        isRetryable: false,
      );
    }

    final prompt = _buildRecipePrompt(ingredients);
    return await _makeRequest(
      endpoint: '/chat/completions',
      body: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful cooking assistant. Generate recipes in JSON format with title, ingredients, steps, cookingTime (in minutes), and difficulty (Easy/Medium/Hard).',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      },
    );
  }

  @override
  Future<String> summarizeText(String text) async {
    if (!isAvailable) {
      throw const AIServiceException(
        'OpenAI service not available. Please check your API key.',
        isRetryable: false,
      );
    }

    final prompt = _buildSummaryPrompt(text);
    return await _makeRequest(
      endpoint: '/chat/completions',
      body: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that creates concise summaries. Return summaries in JSON format with summary text and key points array.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': 500,
        'temperature': 0.3,
      },
    );
  }

  /// Makes HTTP request to OpenAI API with retry logic
  Future<String> _makeRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    int retryCount = 0;

    while (retryCount < _maxRetries) {
      try {
        final response = await _httpClient
            .post(
              Uri.parse('$_baseUrl$endpoint'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_apiKey',
              },
              body: jsonEncode(body),
            )
            .timeout(_defaultTimeout);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final content = responseData['choices'][0]['message']['content'];
          return content;
        } else if (response.statusCode == 429) {
          // Rate limit exceeded - wait and retry
          await _waitBeforeRetry(retryCount);
          retryCount++;
          continue;
        } else if (response.statusCode >= 500) {
          // Server error - retry
          await _waitBeforeRetry(retryCount);
          retryCount++;
          continue;
        } else {
          // Client error - don't retry
          final errorData = jsonDecode(response.body);
          throw AIServiceException(
            'OpenAI API error: ${errorData['error']['message']}',
            technicalDetails: 'Status: ${response.statusCode}',
            isRetryable: false,
          );
        }
      } on SocketException {
        throw const AIServiceException(
          'Network connection failed. Please check your internet connection.',
          isRetryable: true,
        );
      } on http.ClientException {
        throw const AIServiceException(
          'Network request failed. Please try again.',
          isRetryable: true,
        );
      } on FormatException {
        throw const AIServiceException(
          'Invalid response format from OpenAI API.',
          isRetryable: false,
        );
      } catch (e) {
        if (retryCount < _maxRetries - 1) {
          await _waitBeforeRetry(retryCount);
          retryCount++;
          continue;
        }
        throw AIServiceException(
          'Unexpected error occurred: ${e.toString()}',
          isRetryable: true,
        );
      }
    }

    throw const AIServiceException(
      'Maximum retry attempts exceeded. Please try again later.',
      isRetryable: true,
    );
  }

  /// Wait before retrying with exponential backoff
  Future<void> _waitBeforeRetry(int retryCount) async {
    final delay = Duration(seconds: (retryCount + 1) * 2);
    await Future.delayed(delay);
  }

  String _buildRecipePrompt(List<String> ingredients) {
    return '''
Create a recipe using these ingredients: ${ingredients.join(', ')}.
Return the response as a JSON object with this exact structure:
{
  "title": "Recipe Name",
  "ingredients": ["ingredient 1", "ingredient 2"],
  "steps": ["step 1", "step 2"],
  "cookingTime": 30,
  "difficulty": "Easy"
}
''';
  }

  String _buildSummaryPrompt(String text) {
    return '''
Summarize the following text and extract key points:
"$text"

Return the response as a JSON object with this exact structure:
{
  "summary": "Concise summary of the text",
  "keyPoints": ["key point 1", "key point 2", "key point 3"]
}
''';
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
