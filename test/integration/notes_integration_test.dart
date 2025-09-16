import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_ai_mvp/models/note_summary.dart';
import 'package:flutter_ai_mvp/providers/notes_provider.dart';
import 'package:flutter_ai_mvp/services/ai_service_manager.dart';
import 'package:flutter_ai_mvp/services/storage_repository.dart';

// Generate mocks
@GenerateMocks([AIServiceManager, HiveStorageRepository])
import 'notes_integration_test.mocks.dart';

void main() {
  group('Notes Integration Tests', () {
    late NotesProvider notesProvider;
    late MockAIServiceManager mockAIServiceManager;
    late MockHiveStorageRepository<NoteSummary> mockRepository;

    setUp(() {
      mockAIServiceManager = MockAIServiceManager();
      mockRepository = MockHiveStorageRepository<NoteSummary>();
      notesProvider = NotesProvider(
        aiServiceManager: mockAIServiceManager,
        notesRepository: mockRepository,
      );
    });

    tearDown(() {
      notesProvider.dispose();
    });

    group('Text Summarization Workflow', () {
      test('should successfully summarize valid text', () async {
        // Arrange
        final testText =
            'This is a long text that needs to be summarized. ' * 10;
        const mockSummaryJson = '''
        {
          "summary": "This is a test summary of the long text.",
          "keyPoints": ["Point 1", "Point 2", "Point 3"]
        }
        ''';

        when(
          mockAIServiceManager.summarizeText(testText),
        ).thenAnswer((_) async => mockSummaryJson);
        when(mockRepository.save(any, any)).thenAnswer((_) async {});
        when(mockRepository.getAllKeys()).thenAnswer((_) async => []);

        // Act
        final result = await notesProvider.summarizeText(testText);

        // Assert
        expect(result, isNotNull);
        expect(result!.originalText, equals(testText));
        expect(
          result.summary,
          equals('This is a test summary of the long text.'),
        );
        expect(result.keyPoints, hasLength(3));
        expect(notesProvider.summaries, contains(result));
        verify(mockAIServiceManager.summarizeText(testText)).called(1);
        verify(mockRepository.save(any, any)).called(1);
      });

      test('should reject empty text', () async {
        // Act
        final result = await notesProvider.summarizeText('');

        // Assert
        expect(result, isNull);
        expect(notesProvider.error, isNotNull);
        expect(notesProvider.error, contains('enter some text'));
        verifyNever(mockAIServiceManager.summarizeText(any));
      });

      test('should reject text that is too short', () async {
        // Act
        final result = await notesProvider.summarizeText('Short text');

        // Assert
        expect(result, isNull);
        expect(notesProvider.error, isNotNull);
        expect(notesProvider.error, contains('50 characters'));
        verifyNever(mockAIServiceManager.summarizeText(any));
      });

      test('should handle AI service errors gracefully', () async {
        // Arrange
        final testText =
            'This is a long text that needs to be summarized. ' * 10;
        when(
          mockAIServiceManager.summarizeText(testText),
        ).thenThrow(Exception('AI service error'));
        when(mockRepository.getAllKeys()).thenAnswer((_) async => []);

        // Act
        final result = await notesProvider.summarizeText(testText);

        // Assert
        expect(result, isNull);
        expect(notesProvider.error, isNotNull);
        expect(notesProvider.isLoading, isFalse);
        verify(mockAIServiceManager.summarizeText(testText)).called(1);
        verifyNever(mockRepository.save(any, any));
      });
    });

    group('Text Validation', () {
      test('should validate text correctly', () {
        // Test valid text
        final validText =
            'This is a valid text that is long enough for summarization. ' * 2;
        final validation = notesProvider.validateText(validText);
        expect(validation['isValid'], isTrue);
        expect(validation['errors'], isEmpty);

        // Test empty text
        final emptyValidation = notesProvider.validateText('');
        expect(emptyValidation['isValid'], isFalse);
        expect(emptyValidation['errors'], isNotEmpty);

        // Test short text
        final shortValidation = notesProvider.validateText('Short');
        expect(shortValidation['isValid'], isFalse);
        expect(shortValidation['errors'], isNotEmpty);

        // Test text with warnings
        const shortButValidText =
            'This is a text that is just long enough for validation.';
        final warningValidation = notesProvider.validateText(shortButValidText);
        expect(warningValidation['isValid'], isTrue);
        expect(warningValidation['warnings'], isNotEmpty);
      });
    });

    group('Summary Management', () {
      test('should delete summary successfully', () async {
        // Arrange
        final testSummary = NoteSummary(
          id: 'test-id',
          originalText: 'Test text',
          summary: 'Test summary',
          keyPoints: ['Point 1'],
          createdAt: DateTime.now(),
        );

        notesProvider.summaries.add(testSummary);
        when(mockRepository.delete('test-id')).thenAnswer((_) async {});

        // Act
        await notesProvider.deleteSummary('test-id');

        // Assert
        expect(notesProvider.summaries, isEmpty);
        verify(mockRepository.delete('test-id')).called(1);
      });

      test('should search summaries correctly', () {
        // Arrange
        final summary1 = NoteSummary(
          id: '1',
          originalText: 'Flutter development tutorial',
          summary: 'Learn Flutter basics',
          keyPoints: ['Widgets', 'State management'],
          createdAt: DateTime.now(),
        );

        final summary2 = NoteSummary(
          id: '2',
          originalText: 'React development guide',
          summary: 'Learn React fundamentals',
          keyPoints: ['Components', 'Hooks'],
          createdAt: DateTime.now(),
        );

        notesProvider.summaries.addAll([summary1, summary2]);

        // Act & Assert
        final flutterResults = notesProvider.searchSummaries('Flutter');
        expect(flutterResults, hasLength(1));
        expect(flutterResults.first.id, equals('1'));

        final reactResults = notesProvider.searchSummaries('React');
        expect(reactResults, hasLength(1));
        expect(reactResults.first.id, equals('2'));

        final allResults = notesProvider.searchSummaries('');
        expect(allResults, hasLength(2));
      });

      test('should get summary statistics correctly', () {
        // Arrange
        final summary1 = NoteSummary(
          id: '1',
          originalText: 'This is a test text with ten words exactly here.',
          summary: 'Short summary.',
          keyPoints: ['Point 1'],
          createdAt: DateTime.now(),
        );

        final summary2 = NoteSummary(
          id: '2',
          originalText:
              'Another test text with exactly ten words in this sentence.',
          summary: 'Another short summary.',
          keyPoints: ['Point 2'],
          createdAt: DateTime.now(),
        );

        notesProvider.summaries.addAll([summary1, summary2]);

        // Act
        final stats = notesProvider.getSummaryStatistics();

        // Assert
        expect(stats['totalSummaries'], equals(2));
        expect(stats['totalOriginalWords'], equals(20)); // 10 + 10
        expect(stats['totalSummaryWords'], equals(6)); // 2 + 3
        expect(stats['averageOriginalWords'], equals(10.0));
        expect(stats['averageSummaryWords'], equals(3.0));
      });
    });

    group('Loading and Persistence', () {
      test('should load saved summaries on initialization', () async {
        // Arrange
        final testSummary = NoteSummary(
          id: 'test-id',
          originalText: 'Test text',
          summary: 'Test summary',
          keyPoints: ['Point 1'],
          createdAt: DateTime.now(),
        );

        when(mockRepository.getAllKeys()).thenAnswer((_) async => ['test-id']);
        when(
          mockRepository.load('test-id'),
        ).thenAnswer((_) async => testSummary);

        // Create a new provider to test initialization
        final newProvider = NotesProvider(
          aiServiceManager: mockAIServiceManager,
          notesRepository: mockRepository,
        );

        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(newProvider.summaries, hasLength(1));
        expect(newProvider.summaries.first.id, equals('test-id'));

        newProvider.dispose();
      });

      test('should clear all summaries', () async {
        // Arrange
        final testSummary = NoteSummary(
          id: 'test-id',
          originalText: 'Test text',
          summary: 'Test summary',
          keyPoints: ['Point 1'],
          createdAt: DateTime.now(),
        );

        notesProvider.summaries.add(testSummary);
        when(mockRepository.clear()).thenAnswer((_) async {});

        // Act
        await notesProvider.clearAllSummaries();

        // Assert
        expect(notesProvider.summaries, isEmpty);
        verify(mockRepository.clear()).called(1);
      });
    });
  });
}
