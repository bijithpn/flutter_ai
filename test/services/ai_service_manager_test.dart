import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_ai_mvp/services/ai_service_manager.dart';
import 'package:flutter_ai_mvp/services/ai_service.dart';

// Create a mock AI service for testing
class MockAIService extends Mock implements AIService {
  @override
  bool get isAvailable => true;

  @override
  void dispose() {}
}

void main() {
  group('AIServiceManager', () {
    late AIServiceManager manager;
    late MockAIService mockOfflineService;

    setUp(() {
      manager = AIServiceManager();
      mockOfflineService = MockAIService();
    });

    tearDown(() {
      manager.dispose();
    });

    test('should be singleton', () {
      final manager1 = AIServiceManager();
      final manager2 = AIServiceManager();
      expect(identical(manager1, manager2), true);
    });

    test('should throw exception when not initialized', () {
      expect(() => manager.currentService, throwsA(isA<AIServiceException>()));
    });

    test('should set offline service', () {
      expect(
        () => manager.setOfflineService(mockOfflineService),
        returnsNormally,
      );
    });

    test('should provide connectivity stream', () {
      expect(() => manager.connectivityStream, returnsNormally);
    });

    test('should dispose resources properly', () {
      expect(() => manager.dispose(), returnsNormally);
    });

    test('should check service availability when not initialized', () {
      expect(manager.isServiceAvailable, false);
    });

    test('should check online status', () {
      expect(manager.isOnline, isA<bool>());
    });

    test('should handle updateOpenAIApiKey when not initialized', () async {
      expect(() => manager.updateOpenAIApiKey('new-key'), returnsNormally);
    });
  });
}
