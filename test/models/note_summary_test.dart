import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/note_summary.dart';

void main() {
  group('NoteSummary Model Tests', () {
    late NoteSummary testNoteSummary;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 12, 0, 0);
      testNoteSummary = NoteSummary(
        id: 'note_1',
        originalText: 'This is a very long original text that needs to be summarized. It contains multiple sentences and important information that should be condensed into key points.',
        summary: 'Long text summarized into key points.',
        keyPoints: ['Important information', 'Multiple sentences', 'Needs condensing'],
        createdAt: testDate,
      );
    });

    test('should create NoteSummary with all required fields', () {
      expect(testNoteSummary.id, equals('note_1'));
      expect(testNoteSummary.originalText, isNotEmpty);
      expect(testNoteSummary.summary, equals('Long text summarized into key points.'));
      expect(testNoteSummary.keyPoints, hasLength(3));
      expect(testNoteSummary.createdAt, equals(testDate));
    });

    test('should serialize to JSON correctly', () {
      final json = testNoteSummary.toJson();

      expect(json['id'], equals('note_1'));
      expect(json['originalText'], equals(testNoteSummary.originalText));
      expect(json['summary'], equals('Long text summarized into key points.'));
      expect(json['keyPoints'], equals(['Important information', 'Multiple sentences', 'Needs condensing']));
      expect(json['createdAt'], equals(testDate.toIso8601String()));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'note_1',
        'originalText': 'Original text here',
        'summary': 'Summary here',
        'keyPoints': ['Point 1', 'Point 2'],
        'createdAt': testDate.toIso8601String(),
      };

      final noteSummary = NoteSummary.fromJson(json);

      expect(noteSummary.id, equals('note_1'));
      expect(noteSummary.originalText, equals('Original text here'));
      expect(noteSummary.summary, equals('Summary here'));
      expect(noteSummary.keyPoints, equals(['Point 1', 'Point 2']));
      expect(noteSummary.createdAt, equals(testDate));
    });

    test('should create copy with modified fields', () {
      final modifiedNoteSummary = testNoteSummary.copyWith(
        summary: 'Updated summary',
        keyPoints: ['New point 1', 'New point 2'],
      );

      expect(modifiedNoteSummary.id, equals(testNoteSummary.id));
      expect(modifiedNoteSummary.originalText, equals(testNoteSummary.originalText));
      expect(modifiedNoteSummary.summary, equals('Updated summary'));
      expect(modifiedNoteSummary.keyPoints, equals(['New point 1', 'New point 2']));
      expect(modifiedNoteSummary.createdAt, equals(testNoteSummary.createdAt));
    });

    test('should calculate original word count correctly', () {
      final noteSummary = NoteSummary(
        id: 'test',
        originalText: 'This is a test with exactly eight words.',
        summary: 'Test summary',
        keyPoints: [],
        createdAt: testDate,
      );

      expect(noteSummary.originalWordCount, equals(8));
    });

    test('should calculate summary word count correctly', () {
      final noteSummary = NoteSummary(
        id: 'test',
        originalText: 'Original text',
        summary: 'This summary has five words.',
        keyPoints: [],
        createdAt: testDate,
      );

      expect(noteSummary.summaryWordCount, equals(5));
    });

    test('should calculate compression ratio correctly', () {
      final noteSummary = NoteSummary(
        id: 'test',
        originalText: 'This is a test with ten words in total.',
        summary: 'Test with five words.',
        keyPoints: [],
        createdAt: testDate,
      );

      expect(noteSummary.compressionRatio, closeTo(0.44, 0.01)); // 4 words / 9 words ≈ 0.44
    });

    test('should handle zero word count in compression ratio', () {
      final noteSummary = NoteSummary(
        id: 'test',
        originalText: '',
        summary: 'Some summary',
        keyPoints: [],
        createdAt: testDate,
      );

      expect(noteSummary.compressionRatio, equals(0.0));
    });

    test('should determine if summary is effective', () {
      final effectiveSummary = NoteSummary(
        id: 'test',
        originalText: 'This is a very long original text with many words that should be summarized effectively for better understanding and comprehension of the main points.',
        summary: 'Long text summarized effectively with sufficient detail and comprehensive coverage of key points.',
        keyPoints: [],
        createdAt: testDate,
      );

      final ineffectiveSummary = NoteSummary(
        id: 'test',
        originalText: 'Short text.',
        summary: 'This summary is actually longer than the original text somehow.',
        keyPoints: [],
        createdAt: testDate,
      );

      final tooShortSummary = NoteSummary(
        id: 'test',
        originalText: 'This is a long original text with many words.',
        summary: 'Short.',
        keyPoints: [],
        createdAt: testDate,
      );

      expect(effectiveSummary.isEffectiveSummary, isTrue);
      expect(ineffectiveSummary.isEffectiveSummary, isFalse);
      expect(tooShortSummary.isEffectiveSummary, isFalse);
    });

    test('should implement equality correctly', () {
      final noteSummary1 = NoteSummary(
        id: 'note_1',
        originalText: 'Original text',
        summary: 'Summary',
        keyPoints: ['Point 1'],
        createdAt: testDate,
      );

      final noteSummary2 = NoteSummary(
        id: 'note_1',
        originalText: 'Original text',
        summary: 'Summary',
        keyPoints: ['Point 1'],
        createdAt: testDate,
      );

      final noteSummary3 = noteSummary1.copyWith(summary: 'Different summary');

      expect(noteSummary1, equals(noteSummary2));
      expect(noteSummary1, isNot(equals(noteSummary3)));
    });

    test('should have proper toString implementation', () {
      final string = testNoteSummary.toString();
      expect(string, contains('note_1'));
      expect(string, contains('originalWords'));
      expect(string, contains('summaryWords'));
    });

    test('should validate JSON round-trip', () {
      final json = testNoteSummary.toJson();
      final deserializedNoteSummary = NoteSummary.fromJson(json);
      final reserializedJson = deserializedNoteSummary.toJson();

      expect(json, equals(reserializedJson));
      expect(testNoteSummary, equals(deserializedNoteSummary));
    });

    test('should handle whitespace in word counting', () {
      final noteSummary = NoteSummary(
        id: 'test',
        originalText: '  This   has   extra   spaces  ',
        summary: '\tThis\nhas\r\nspecial\twhitespace\n',
        keyPoints: [],
        createdAt: testDate,
      );

      expect(noteSummary.originalWordCount, equals(4));
      expect(noteSummary.summaryWordCount, equals(4));
    });
  });
}