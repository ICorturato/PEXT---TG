import 'package:flutter_test/flutter_test.dart';
import 'package:pext/models/dashboard_analytics_models.dart';

void main() {
  group('AI Assistant Dashboard Analytics Model & Parsing Tests', () {
    test('AIAnalytics.fromJson parses complete JSON payload correctly', () {
      final json = {
        'conversations': {
          'value': 256,
          'delta': 8.5,
          'isIncrease': true,
          'positive': true,
          'formattedValue': '256',
          'trendText': '8,5%',
          'subtitle': 'vs 30 dias ant.',
        },
        'answeredDoubts': {
          'value': 97,
          'delta': 2.1,
          'isIncrease': true,
          'positive': true,
          'formattedValue': '97',
          'trendText': '2,1%',
          'subtitle': 'vs 30 dias ant.',
        },
        'unansweredDoubts': {
          'value': 32,
          'delta': 3.2,
          'isIncrease': true,
          'positive': false,
          'formattedValue': '32',
          'trendText': '3,2%',
          'subtitle': 'vs 30 dias ant.',
        },
        'unansweredByTopic': [
          {'name': 'Polímeros', 'count': 46},
          {'name': 'Matriz', 'count': 26},
          {'name': 'Processo de Extrusão', 'count': 15},
          {'name': 'Resfriamento', 'count': 32},
          {'name': 'Outros', 'count': 63},
        ],
        'contents': {
          'total': {
            'value': 256,
            'delta': 8.5,
            'isIncrease': true,
            'positive': true,
            'formattedValue': '256',
          },
          'updated': {
            'value': 97,
            'delta': 2.1,
            'isIncrease': true,
            'positive': true,
            'formattedValue': '97',
          },
          'new': {
            'value': 32,
            'delta': 3.2,
            'isIncrease': true,
            'positive': true,
            'formattedValue': '32',
          },
        },
        'aiInteractionsOverTime': [
          4.0, 5.0, 8.0, 12.0, 11.0, 14.0, 13.0, 16.0, 15.0, 13.0,
          17.0, 19.0, 18.0, 22.0, 21.0, 24.0, 26.0, 25.0, 28.0, 30.0,
          27.0, 31.0, 33.0, 36.0, 38.0, 35.0, 39.0, 42.0, 44.0, 48.0
        ],
      };

      final aiAnalytics = AIAnalytics.fromJson(json);

      expect(aiAnalytics.conversations.value, 256);
      expect(aiAnalytics.conversations.isIncrease, true);
      expect(aiAnalytics.answeredDoubts.value, 97);
      expect(aiAnalytics.unansweredDoubts.value, 32);

      expect(aiAnalytics.unansweredByTopic.length, 5);
      expect(aiAnalytics.unansweredByTopic[0].label, 'Polímeros');
      expect(aiAnalytics.unansweredByTopic[0].value, 46.0);

      expect(aiAnalytics.contentsTotal.value, 256);
      expect(aiAnalytics.contentsUpdated.value, 97);
      expect(aiAnalytics.contentsNew.value, 32);

      expect(aiAnalytics.aiInteractionsOverTime.length, 30);
      expect(aiAnalytics.aiInteractionsOverTime.first, 4.0);
      expect(aiAnalytics.aiInteractionsOverTime.last, 48.0);
    });

    test('AIAnalytics.fromJson handles empty or fallback map without errors', () {
      final aiAnalytics = AIAnalytics.fromJson({});

      expect(aiAnalytics.conversations.value, 256);
      expect(aiAnalytics.answeredDoubts.value, 97);
      expect(aiAnalytics.unansweredDoubts.value, 32);
      expect(aiAnalytics.unansweredByTopic.length, 5);
      expect(aiAnalytics.contentsTotal.value, 256);
      expect(aiAnalytics.contentsUpdated.value, 97);
      expect(aiAnalytics.contentsNew.value, 32);
      expect(aiAnalytics.aiInteractionsOverTime.length, 13);
    });
  });
}
