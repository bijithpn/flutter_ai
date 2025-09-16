import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider for managing note summarization and storage
class NotesProvider extends ChangeNotifier {
  final AIServiceManager _aiServiceManager;
  final HiveStorageRepository<NoteSummary> _notesRepository;

  List<NoteSummary> _summaries = [];
  bool _isLoading = false;
  String? _error;
  String _currentText = '';

  NotesProvider({
    required AIServiceManager aiServiceManager,
    required HiveStorageRepository<NoteSummary> notesRepository,
  }) : _aiServiceManager = aiServiceManager,
       _notesRepository = notesRepository {
    _loadSavedSummaries();
  }

  // Getters
  List<NoteSummary> get summaries => _summaries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentText => _currentText;
  bool get hasSummaries => _summaries.isNotEmpty;

  /// Summarize text using AI service
  Future<NoteSummary?> summarizeText(String text) async {
    if (text.trim().isEmpty) {
      _setError('Please enter some text to summarize');
      return null;
    }

    if (text.trim().length < 50) {
      _setError(
        'Text should be at least 50 characters long for better summarization',
      );
      return null;
    }

    _setLoading(true);
    _clearError();
    _currentText = text;

    try {
      // Check if we have a cached summary for this text
      final cachedSummary = await _getCachedSummary(text);
      if (cachedSummary != null) {
        _setLoading(false);
        return cachedSummary;
      }

      // Generate new summary using AI service
      final summaryJson = await _aiServiceManager.summarizeText(text);
      final summary = await _parseAndSaveSummary(summaryJson, text);

      // Add to local list and notify listeners
      _summaries.insert(0, summary);
      notifyListeners();

      return summary;
    } catch (e, stackTrace) {
      debugPrint('Error in summarizeText: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Parse summary JSON and create NoteSummary object
  Future<NoteSummary> _parseAndSaveSummary(
    String summaryJson,
    String originalText,
  ) async {
    try {
      final Map<String, dynamic> parsedJson = jsonDecode(summaryJson);

      final summary = NoteSummary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalText: originalText,
        summary: parsedJson['summary'] ?? 'Summary not available',
        keyPoints: List<String>.from(parsedJson['keyPoints'] ?? []),
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _notesRepository.save(summary.id, summary);

      return summary;
    } catch (e) {
      throw Exception('Failed to parse summary data: $e');
    }
  }

  /// Get cached summary for text (based on text hash)
  Future<NoteSummary?> _getCachedSummary(String text) async {
    final textHash = text.hashCode.toString();
    return await _notesRepository.load('cache_$textHash');
  }

  /// Load all saved summaries from storage
  Future<void> _loadSavedSummaries() async {
    try {
      final allKeys = await _notesRepository.getAllKeys();
      final regularSummaryKeys = allKeys.where(
        (key) => !key.startsWith('cache_'),
      );

      _summaries = [];
      for (final key in regularSummaryKeys) {
        final summary = await _notesRepository.load(key);
        if (summary != null) {
          _summaries.add(summary);
        }
      }

      // Sort by creation date (newest first)
      _summaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load saved summaries: $e');
    }
  }

  /// Get summary by ID
  Future<NoteSummary?> getSummaryById(String id) async {
    try {
      return await _notesRepository.load(id);
    } catch (e) {
      debugPrint('Failed to load summary $id: $e');
      return null;
    }
  }

  /// Delete summary
  Future<void> deleteSummary(String id) async {
    try {
      await _notesRepository.delete(id);
      _summaries.removeWhere((summary) => summary.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete summary: $e');
    }
  }

  /// Delete multiple summaries
  Future<void> deleteSummaries(List<String> ids) async {
    try {
      for (final id in ids) {
        await _notesRepository.delete(id);
      }
      _summaries.removeWhere((summary) => ids.contains(summary.id));
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete summaries: $e');
    }
  }

  /// Clear all summaries
  Future<void> clearAllSummaries() async {
    try {
      await _notesRepository.clear();
      _summaries.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear summaries: $e');
    }
  }

  /// Reload summaries from storage
  Future<void> reloadSummaries() async {
    await _loadSavedSummaries();
  }

  /// Search summaries by text content
  List<NoteSummary> searchSummaries(String query) {
    if (query.isEmpty) return _summaries;

    final lowercaseQuery = query.toLowerCase();
    return _summaries.where((summary) {
      return summary.summary.toLowerCase().contains(lowercaseQuery) ||
          summary.originalText.toLowerCase().contains(lowercaseQuery) ||
          summary.keyPoints.any(
            (point) => point.toLowerCase().contains(lowercaseQuery),
          );
    }).toList();
  }

  /// Get summaries by date range
  List<NoteSummary> getSummariesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _summaries.where((summary) {
      return summary.createdAt.isAfter(startDate) &&
          summary.createdAt.isBefore(endDate);
    }).toList();
  }

  /// Get summaries created today
  List<NoteSummary> getTodaysSummaries() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSummariesByDateRange(startOfDay, endOfDay);
  }

  /// Get summaries by compression ratio range
  List<NoteSummary> getSummariesByCompressionRatio(
    double minRatio,
    double maxRatio,
  ) {
    return _summaries.where((summary) {
      final ratio = summary.compressionRatio;
      return ratio >= minRatio && ratio <= maxRatio;
    }).toList();
  }

  /// Get most effective summaries (high compression, good length)
  List<NoteSummary> getEffectiveSummaries() {
    return _summaries.where((summary) => summary.isEffectiveSummary).toList();
  }

  /// Get statistics about summaries
  Map<String, dynamic> getSummaryStatistics() {
    if (_summaries.isEmpty) {
      return {
        'totalSummaries': 0,
        'averageCompressionRatio': 0.0,
        'totalOriginalWords': 0,
        'totalSummaryWords': 0,
        'averageOriginalWords': 0.0,
        'averageSummaryWords': 0.0,
      };
    }

    final totalOriginalWords = _summaries.fold<int>(
      0,
      (sum, summary) => sum + summary.originalWordCount,
    );
    final totalSummaryWords = _summaries.fold<int>(
      0,
      (sum, summary) => sum + summary.summaryWordCount,
    );
    final averageCompressionRatio =
        _summaries.fold<double>(
          0.0,
          (sum, summary) => sum + summary.compressionRatio,
        ) /
        _summaries.length;

    return {
      'totalSummaries': _summaries.length,
      'averageCompressionRatio': averageCompressionRatio,
      'totalOriginalWords': totalOriginalWords,
      'totalSummaryWords': totalSummaryWords,
      'averageOriginalWords': totalOriginalWords / _summaries.length,
      'averageSummaryWords': totalSummaryWords / _summaries.length,
    };
  }

  /// Validate text before summarization
  Map<String, dynamic> validateText(String text) {
    final trimmedText = text.trim();
    final wordCount = trimmedText.isEmpty
        ? 0
        : trimmedText.split(RegExp(r'\s+')).length;

    final validation = {
      'isValid': true,
      'errors': <String>[],
      'warnings': <String>[],
      'wordCount': wordCount,
      'characterCount': trimmedText.length,
    };

    if (trimmedText.isEmpty) {
      validation['isValid'] = false;
      validation['errors'] = ['Text cannot be empty'];
      return validation;
    }

    if (trimmedText.length < 50) {
      validation['isValid'] = false;
      validation['errors'] = ['Text should be at least 50 characters long'];
      return validation;
    }

    if (wordCount < 10) {
      validation['warnings'] = [
        'Text with fewer than 10 words may not produce meaningful summaries',
      ];
    }

    if (wordCount > 2000) {
      validation['warnings'] = [
        'Very long texts may be truncated. Consider breaking into smaller sections.',
      ];
    }

    return validation;
  }

  /// Update current text being edited
  void updateCurrentText(String text) {
    _currentText = text;
    _clearError();
    notifyListeners();
  }

  /// Clear current text
  void clearCurrentText() {
    _currentText = '';
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AIServiceException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  void dispose() {
    _notesRepository.close();
    super.dispose();
  }
}
