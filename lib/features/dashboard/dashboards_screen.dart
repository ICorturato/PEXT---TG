import 'package:flutter/material.dart';
import '../../models/dashboard_analytics_models.dart';
import '../../services/analytics_repository.dart';
import '../../shared/widgets/dashboard/dashboard_widgets.dart';

sealed class DashboardState {
  const DashboardState();
  factory DashboardState.loading() => const DashboardLoadingState();
  factory DashboardState.loaded({
    required OverviewAnalytics overview,
    required ProblemsAnalytics problems,
    required TrainingAnalytics trainings,
    required AIAnalytics ai,
  }) =>
      DashboardLoadedState(
        overview: overview,
        problems: problems,
        trainings: trainings,
        ai: ai,
      );
  factory DashboardState.error(String message) => DashboardErrorState(message);
}

class DashboardLoadingState extends DashboardState {
  const DashboardLoadingState();
}

class DashboardLoadedState extends DashboardState {
  final OverviewAnalytics overview;
  final ProblemsAnalytics problems;
  final TrainingAnalytics trainings;
  final AIAnalytics ai;

  const DashboardLoadedState({
    required this.overview,
    required this.problems,
    required this.trainings,
    required this.ai,
  });
}

class DashboardErrorState extends DashboardState {
  final String message;
  const DashboardErrorState(this.message);
}

class DashboardNotifier extends ValueNotifier<DashboardState> {
  final AnalyticsRepository _repo;

  DashboardNotifier([AnalyticsRepository? repo])
      : _repo = repo ?? AnalyticsRepository.instance,
        super(DashboardState.loading()) {
    loadAllDashboards();
  }

  DashboardState get state => value;
  set state(DashboardState newState) => value = newState;

  Future<void> loadAllDashboards({bool force = false}) async {
    if (!force && value is DashboardLoadedState) return;
    state = DashboardState.loading();
    try {
      final results = await Future.wait([
        _repo.fetchOverviewMetrics(),
        _repo.fetchProblemsMetrics(),
        _repo.fetchTrainingMetrics(),
        _repo.fetchAIMetrics(),
      ]);

      state = DashboardState.loaded(
        overview: results[0] as OverviewAnalytics,
        problems: results[1] as ProblemsAnalytics,
        trainings: results[2] as TrainingAnalytics,
        ai: results[3] as AIAnalytics,
      );
    } catch (e) {
      state = DashboardState.error(e.toString());
    }
  }
}

class DashboardsScreen extends StatefulWidget {
  final DashboardNotifier? notifier;
  final int initialTab;

  const DashboardsScreen({
    super.key,
    this.notifier,
    this.initialTab = 0,
  });

  @override
  State<DashboardsScreen> createState() => _DashboardsScreenState();
}

class _DashboardsScreenState extends State<DashboardsScreen> {
  late final DashboardNotifier _notifier;
  late int _currentTab;
  bool _ownsNotifier = false;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    if (widget.notifier != null) {
      _notifier = widget.notifier!;
    } else {
      _notifier = DashboardNotifier();
      _ownsNotifier = true;
    }
  }

  @override
  void dispose() {
    if (_ownsNotifier) {
      _notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DashboardState>(
      valueListenable: _notifier,
      builder: (context, state, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedHeaderNavigation(
              selectedIndex: _currentTab,
              onTabSelected: (index) {
                if (_currentTab != index) {
                  setState(() => _currentTab = index);
                }
              },
            ),
            const SizedBox(height: 16),
            if (state is DashboardLoadingState)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF132B5C)),
                ),
              )
            else if (state is DashboardErrorState)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Erro ao carregar dados: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _notifier.loadAllDashboards(force: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF132B5C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state is DashboardLoadedState)
              _buildTabContent(state),
          ],
        );
      },
    );
  }

  Widget _buildTabContent(DashboardLoadedState state) {
    switch (_currentTab) {
      case 0:
        return _OverviewTabView(overview: state.overview);
      case 1:
        return _ProblemsTabView(problems: state.problems);
      case 2:
        return _TrainingsTabView(trainings: state.trainings);
      case 3:
      default:
        return _AIAssistantTabView(ai: state.ai);
    }
  }
}

class _OverviewTabView extends StatelessWidget {
  final OverviewAnalytics overview;
  const _OverviewTabView({required this.overview});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Problemas Reportados',
                metric: overview.problemsReported,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Solicitações de Ajuda',
                metric: overview.helpRequests,
                compact: true,
                overrideTitleColor: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Resolução pelo Sistema',
                metric: overview.systemResolutionRate,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Dúvidas não respondidas (IA)',
                metric: overview.unansweredDoubts,
                compact: true,
                overrideTitleColor: const Color(0xFFEAB308),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Treinamentos Concluídos',
                metric: overview.trainingsCompleted,
                compact: true,
                overrideTitleColor: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Aprovação Média',
                metric: overview.averageApprovalRate,
                compact: true,
                overrideTitleColor: const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TimeSeriesLineChartCard(
          title: 'Evolução Geral',
          height: 210,
          labels: overview.evolutionLabels,
          series: [
            ChartLineSeries(
              label: 'Solicitação de ajuda',
              color: const Color(0xFFDC2626),
              values: overview.helpRequestsSeries,
            ),
            ChartLineSeries(
              label: 'Problemas reportados',
              color: const Color(0xFF2563EB),
              values: overview.problemsReportedSeries,
            ),
            ChartLineSeries(
              label: 'Resolução pelo sistema',
              color: const Color(0xFF16A34A),
              values: overview.systemResolutionSeries,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProblemsTabView extends StatelessWidget {
  final ProblemsAnalytics problems;
  const _ProblemsTabView({required this.problems});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Total de Problemas',
                metric: problems.totalProblems,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Resolvidos pelo Sistema',
                metric: problems.resolvedBySystem,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Encaminhados ao ADM',
                metric: problems.forwardedToAdmin,
                compact: true,
                overrideTitleColor: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Resolução por Supervisão & Materiais',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF132B5C),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Taxa Resolução Supervisor',
                metric: problems.supervisorResolutionRate,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Materiais Catalogados',
                metric: problems.totalMaterials,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DonutChartCard(
          title: 'Problemas por categoria',
          slices: problems.problemsByCategory,
        ),
        const SizedBox(height: 20),
        HorizontalBarChartCard(
          title: 'Problemas por produto',
          items: problems.problemsByProduct,
        ),
        const SizedBox(height: 20),
        TimeSeriesLineChartCard(
          title: 'Problemas ao longo do tempo',
          height: 160,
          series: [
            ChartLineSeries(
              label: 'Problemas',
              color: const Color(0xFF1768DF),
              values: problems.problemsOverTime,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Solicitações',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF132B5C),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Total de Solicitações',
                metric: problems.requestsTotal,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Novas',
                metric: problems.requestsNew,
                compact: true,
                overrideTitleColor: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Em andamento',
                metric: problems.requestsInProgress,
                compact: true,
                overrideTitleColor: const Color(0xFFEAB308),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Concluídas',
                metric: problems.requestsResolved,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DonutChartCard(
          title: 'Solicitações por Status',
          slices: problems.requestsByStatus,
        ),
        const SizedBox(height: 20),
        SparklineKpiCard.fromMetric(
          title: 'Tempo Médio até a Conclusão',
          metric: problems.averageResolutionTime,
        ),
        const SizedBox(height: 20),
        HorizontalBarChartCard(
          title: 'Problemas que geram mais solicitações',
          items: problems.topEscalatedProblems,
        ),
      ],
    );
  }
}

class _TrainingsTabView extends StatelessWidget {
  final TrainingAnalytics trainings;
  const _TrainingsTabView({required this.trainings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Total Treinamentos',
                metric: trainings.totalTrainings,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Em andamento',
                metric: trainings.inProgress,
                compact: true,
                overrideTitleColor: const Color(0xFFEAB308),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Concluídos',
                metric: trainings.completed,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Taxa Desistência',
                metric: trainings.dropoutRate,
                compact: true,
                overrideTitleColor: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        HorizontalBarChartCard(
          title: 'Ranking de Cursos (Maior Desistência / Reprovação)',
          items: trainings.courseRankings,
        ),
        const SizedBox(height: 20),
        DonutChartCard(
          title: 'Taxa de Aprovação vs Reprovação',
          slices: trainings.approvalVsFailure,
        ),
        const SizedBox(height: 20),
        DonutChartCard(
          title: 'Situação dos usuários',
          slices: trainings.userStatus,
        ),
        const SizedBox(height: 20),
        SparklineKpiCard.fromMetric(
          title: 'Média de Acertos nas Avaliações',
          metric: trainings.averageAssessmentScore,
        ),
      ],
    );
  }
}

class _AIAssistantTabView extends StatelessWidget {
  final AIAnalytics ai;
  const _AIAssistantTabView({required this.ai});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Conversas',
                metric: ai.conversations,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Dúvidas respondidas',
                metric: ai.answeredDoubts,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Dúvidas não respondidas',
                metric: ai.unansweredDoubts,
                compact: true,
                overrideTitleColor: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        HorizontalBarChartCard(
          title: 'Dúvidas não respondidas',
          items: ai.unansweredByTopic,
        ),
        const SizedBox(height: 20),
        const Text(
          'Conteúdos cadastrados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF132B5C),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Total de conteúdos',
                metric: ai.contentsTotal,
                compact: true,
                overrideTitleColor: const Color(0xFF0B4AA0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Atualizados',
                metric: ai.contentsUpdated,
                compact: true,
                overrideTitleColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: KpiCard.fromMetric(
                title: 'Novos',
                metric: ai.contentsNew,
                compact: true,
                overrideTitleColor: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TimeSeriesLineChartCard(
          title: 'Interações com IA',
          height: 210,
          series: [
            ChartLineSeries(
              label: 'Interações',
              color: const Color(0xFF1768DF),
              values: ai.aiInteractionsOverTime,
            ),
          ],
        ),
      ],
    );
  }
}
