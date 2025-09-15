import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/services/openai_service.dart';
import '../../lib/services/ai_service.dart';
import 'openai_service_test.mocks.dart';

// Generate mocks
@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  group('OpenAIService', () {
    late OpenAIService service;
    late MockClient mockHttpClient;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockHttpClient = MockClient();
      mockSecureStorage = MockFlutterSecureStorage();
      service = OpenAIService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );
    });

    tearDown(() {
      service.dispose();
    });

    group('initialization', () {
      test('should not be available initially', () {
        expect(service.isAvailable, false);
      });

      test('should be available after initialization with API key', () async {
        const apiKey = 'test-api-key';
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});

        await service.initialize(apiKey);

        expect(service.isAvailable, true);
        verify(mockSecureStorage.write(key: 'openai_api_key', value: apiKey));
      });

      test('should load API key from secure storage', () async {
        const apiKey = 'stored-api-key';
        when(
          mockSecureStorage.read(key: 'openai_api_key'),
        ).thenAnswer((_) async => apiKey);

        await service.loadApiKey();

        expect(service.isAvailable, true);
        verify(mockSecureStorage.read(key: 'openai_api_key'));
      });
    });

    group('generateRecipe', () {
      setUp(() async {
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});
        await service.initialize('test-api-key');
      });

      test('should generate recipe successfully', () async {
        final mockResponse = http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'title': 'Test Recipe',
                    'ingredients': ['ingredient1', 'ingredient2'],
                    'steps': ['step1', 'step2'],
                    'cookingTime': 30,
                    'difficulty': 'Easy',
                  }),
                },
              },
            ],
          }),
          200,
        );

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await service.generateRecipe(['tomato', 'cheese']);

        expect(result, isA<String>());
        verify(
          mockHttpClient.post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test-api-key',
            },
            body: anyNamed('body'),
          ),
        );
      });

      test('should throw AIServiceException when not available', () async {
        final uninitializedService = OpenAIService(
          httpClient: mockHttpClient,
          secureStorage: mockSecureStorage,
        );

        expect(
          () => uninitializedService.generateRecipe(['tomato']),
          throwsA(isA<AIServiceException>()),
        );
      });

      test('should handle network errors', () async {
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenThrow(const SocketException('Network error'));

        expect(
          () => service.generateRecipe(['tomato']),
          throwsA(isA<AIServiceException>()),
        );
      });

      test('should handle rate limiting with retry', () async {
        final rateLimitResponse = http.Response('Rate limit exceeded', 429);
        final successResponse = http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'title': 'Test Recipe',
                    'ingredients': ['ingredient1'],
                    'steps': ['step1'],
                    'cookingTime': 15,
                    'difficulty': 'Easy',
                  }),
                },
              },
            ],
          }),
          200,
        );

        var callCount = 0;
        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return rateLimitResponse;
          } else {
            return successResponse;
          }
        });

        final result = await service.generateRecipe(['tomato']);

        expect(result, isA<String>());
        verify(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(2);
      });
    });

    group('summarizeText', () {
      setUp(() async {
        when(
          mockSecureStorage.write(
            key: anyNamed('key'),
            value: anyNamed('value'),
          ),
        ).thenAnswer((_) async {});
        await service.initialize('test-api-key');
      });

      test('should summarize text successfully', () async {
        final mockResponse = http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'summary': 'This is a test summary',
                    'keyPoints': ['point1', 'point2'],
                  }),
                },
              },
            ],
          }),
          200,
        );

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await service.summarizeText(
          'This is a long text to summarize',
        );

        expect(result, isA<String>());
        verify(
          mockHttpClient.post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test-api-key',
            },
            body: anyNamed('body'),
          ),
        );
      });

      test('should throw AIServiceException when not available', () async {
        final uninitializedService = OpenAIService(
          httpClient: mockHttpClient,
          secureStorage: mockSecureStorage,
        );

        expect(
          () => uninitializedService.summarizeText('test text'),
          throwsA(isA<AIServiceException>()),
        );
      });

      test('should handle API errors', () async {
        final errorResponse = http.Response(
          jsonEncode({
            'error': {'message': 'Invalid API key'},
          }),
          401,
        );

        when(
          mockHttpClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => errorResponse);

        expect(
          () => service.summarizeText('test text'),
          throwsA(isA<AIServiceException>()),
        );
      });
    });
  });
}
