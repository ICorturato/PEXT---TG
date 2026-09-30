import '../models/dashboard_analytics_models.dart';
import 'api_client.dart';

class AnalyticsRepository {
  final ApiClient _client;

  AnalyticsRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  static final AnalyticsRepository instance = AnalyticsRepository();

  Future<OverviewAnalytics> fetchOverviewMetrics({String period = '30d'}) async {
    try {
      final res = await _client.getAnalytics('overview', period: period);
      return OverviewAnalytics.fromJson(res);
    } catch (_) {
      try {
        final fallback = await _client.getTrainingAnalytics();
        return OverviewAnalytics.fromJson(fallback['overview'] as Map<String, dynamic>? ?? fallback);
      } catch (_) {
        return OverviewAnalytics.fromJson(const {});
      }
    }
  }

  Future<ProblemsAnalytics> fetchProblemsMetrics({String period = '30d'}) async {
    try {
      final res = await _client.getAnalytics('problems', period: period);
      return ProblemsAnalytics.fromJson(res);
    } catch (_) {
      try {
        final fallback = await _client.getTrainingAnalytics();
        return ProblemsAnalytics.fromJson(fallback['problems'] as Map<String, dynamic>? ?? fallback);
      } catch (_) {
        return ProblemsAnalytics.fromJson(const {});
      }
    }
  }

  Future<TrainingAnalytics> fetchTrainingMetrics({String period = '30d'}) async {
    try {
      final res = await _client.getAnalytics('trainings', period: period);
      return TrainingAnalytics.fromJson(res);
    } catch (_) {
      try {
        final fallback = await _client.getTrainingAnalytics();
        return TrainingAnalytics.fromJson(fallback['trainings'] as Map<String, dynamic>? ?? fallback);
      } catch (_) {
        return TrainingAnalytics.fromJson(const {});
      }
    }
  }

  Future<AIAnalytics> fetchAIMetrics({String period = '30d'}) async {
    try {
      final res = await _client.getAnalytics('ai', period: period);
      return AIAnalytics.fromJson(res);
    } catch (_) {
      try {
        final fallback = await _client.getTrainingAnalytics();
        return AIAnalytics.fromJson(fallback['ai'] as Map<String, dynamic>? ?? fallback);
      } catch (_) {
        return AIAnalytics.fromJson(const {});
      }
    }
  }
}

final analyticsRepositoryProvider = AnalyticsRepository.instance;
