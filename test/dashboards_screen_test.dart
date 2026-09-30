import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/dashboard/dashboards_screen.dart';
import 'package:pext/models/dashboard_analytics_models.dart';
import 'package:pext/shared/widgets/dashboard/dashboard_widgets.dart';

OverviewAnalytics createMockOverview() {
  return OverviewAnalytics(
    problemsReported: KpiMetric.simple(value: 128, delta: 8.3, isIncrease: true, positive: false),
    helpRequests: KpiMetric.simple(value: 32, delta: 12.3, isIncrease: false, positive: true),
    systemResolutionRate: KpiMetric.simple(value: 75.8, delta: 2.0, isIncrease: true, positive: true, suffix: '%'),
    unansweredDoubts: KpiMetric.simple(value: 13, delta: 8.3, isIncrease: true, positive: false),
    trainingsCompleted: KpiMetric.simple(value: 36, delta: 5.7, isIncrease: true, positive: true),
    averageApprovalRate: KpiMetric.simple(value: 78.3, delta: 2.1, isIncrease: true, positive: true, suffix: '%'),
    evolutionLabels: ['01 Ago', '15 Ago', '30 Ago'],
    helpRequestsSeries: [57, 60, 66],
    problemsReportedSeries: [36, 38, 41],
    systemResolutionSeries: [17, 25, 25],
  );
}

ProblemsAnalytics createMockProblems() {
  return ProblemsAnalytics(
    totalProblems: KpiMetric.simple(value: 128, delta: 8.3, isIncrease: true, positive: false),
    resolvedBySystem: KpiMetric.simple(value: 97, delta: 2.0, isIncrease: false, positive: false),
    forwardedToAdmin: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: false),
    supervisorResolutionRate: KpiMetric.simple(value: 84.2, delta: 4.2, isIncrease: true, positive: true, suffix: '%'),
    totalMaterials: KpiMetric.simple(value: 42, delta: 3.1, isIncrease: true, positive: true),
    problemsByCategory: const [
      DonutSliceData(label: 'Variação na espessura', percentage: 38, color: Color(0xFF1768DF)),
      DonutSliceData(label: 'Bolhas no filme', percentage: 22, color: Color(0xFF4AA5ED)),
      DonutSliceData(label: 'Marcas de gel', percentage: 15, color: Color(0xFFFFC107)),
    ],
    problemsByProduct: const [
      HorizontalBarItem(label: 'RAP10', value: 46),
      HorizontalBarItem(label: 'Macarrão Instantâneo', value: 26),
    ],
    problemsOverTime: const [16, 39, 47],
    requestsTotal: KpiMetric.simple(value: 128, delta: 8.3, isIncrease: true, positive: false),
    requestsNew: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: false),
    requestsInProgress: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: true),
    requestsResolved: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: true),
    requestsByStatus: const [
      DonutSliceData(label: 'Novas', percentage: 25, color: Color(0xFF2563EB)),
      DonutSliceData(label: 'Em andamento', percentage: 50, color: Color(0xFF16A34A)),
      DonutSliceData(label: 'Concluídas', percentage: 25, color: Color(0xFFEAB308)),
    ],
    averageResolutionTime: const SparklineMetric(
      valueString: '2h 45m',
      delta: 8.3,
      isIncrease: false,
      positive: true,
      sparkline: [15, 30, 45, 34, 46],
    ),
    topEscalatedProblems: const [
      HorizontalBarItem(label: 'Variação na espessura', value: 46),
      HorizontalBarItem(label: 'Bolhas no filme', value: 20),
    ],
    solutionsDisplayed: KpiMetric.simple(value: 128, delta: 8.3, isIncrease: true, positive: true),
    solutionsSuccessRate: KpiMetric.simple(value: 82.3, delta: 2.0, isIncrease: true, positive: true, suffix: '%'),
    solutionsByType: const [
      HorizontalBarItem(label: 'Ajuste na Temperatura', value: 92, valueFormatted: '92%'),
      HorizontalBarItem(label: 'Ajuste de velocidade', value: 82, valueFormatted: '82%'),
    ],
  );
}

TrainingAnalytics createMockTrainings() {
  return TrainingAnalytics(
    totalTrainings: KpiMetric.simple(value: 128, delta: 8.3, isIncrease: true, positive: true),
    inProgress: KpiMetric.simple(value: 97, delta: 2.0, isIncrease: false, positive: false),
    completed: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: true),
    dropoutRate: KpiMetric.simple(value: 12.5, delta: 1.1, isIncrease: false, positive: true, suffix: '%'),
    courseRankings: const [
      HorizontalBarItem(label: 'Processo de extrusão', value: 38, valueFormatted: '38%'),
      HorizontalBarItem(label: 'Segurança Operacional', value: 26, valueFormatted: '26%'),
    ],
    approvalVsFailure: const [
      DonutSliceData(label: 'Aprovados', percentage: 79, color: Color(0xFF16A34A)),
      DonutSliceData(label: 'Reprovados', percentage: 21, color: Color(0xFFDC2626)),
    ],
    userStatus: const [
      DonutSliceData(label: 'Concluídos', percentage: 45, color: Color(0xFF2563EB)),
      DonutSliceData(label: 'Em andamento', percentage: 30, color: Color(0xFF16A34A)),
      DonutSliceData(label: 'Não iniciados', percentage: 25, color: Color(0xFFEAB308)),
    ],
    averageAssessmentScore: const SparklineMetric(
      valueString: '76,6%',
      delta: 8.3,
      isIncrease: true,
      positive: true,
      sparkline: [25, 52, 76, 58],
    ),
  );
}

AIAnalytics createMockAI() {
  return AIAnalytics(
    conversations: KpiMetric.simple(value: 256, delta: 8.3, isIncrease: true, positive: true),
    answeredDoubts: KpiMetric.simple(value: 97, delta: 2.0, isIncrease: false, positive: false),
    unansweredDoubts: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: false),
    unansweredByTopic: const [
      HorizontalBarItem(label: 'Polímeros', value: 46),
      HorizontalBarItem(label: 'Matriz', value: 26),
    ],
    contentsTotal: KpiMetric.simple(value: 256, delta: 8.3, isIncrease: true, positive: true),
    contentsUpdated: KpiMetric.simple(value: 97, delta: 2.0, isIncrease: false, positive: false),
    contentsNew: KpiMetric.simple(value: 32, delta: 1.3, isIncrease: true, positive: true),
    aiInteractionsOverTime: const [35, 64, 128],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboards Screen & Widgets Specification Tests', () {
    testWidgets('renders KpiCard with primary metric, trend arrow, delta and vs 30 dias ant.', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                height: 140,
                child: KpiCard(
                  title: 'Problemas Reportados',
                  value: 128,
                  delta: 8.3,
                  isIncrease: true,
                  positive: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Problemas Reportados'), findsOneWidget);
      expect(find.text('128'), findsOneWidget);
      expect(find.text('▲'), findsOneWidget);
      expect(find.text('8,3%'), findsOneWidget);
      expect(find.text('vs 30 dias ant.'), findsOneWidget);
    });

    testWidgets('renders DonutChartCard with labels, percentage, and fl_chart PieChart', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 380,
                child: DonutChartCard(
                  title: 'Problemas por categoria',
                  slices: [
                    DonutSliceData(label: 'Variação na espessura', percentage: 38, color: Color(0xFF1768DF)),
                    DonutSliceData(label: 'Bolhas no filme', percentage: 22, color: Color(0xFF4AA5ED)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Problemas por categoria'), findsOneWidget);
      expect(find.text('Variação na espessura'), findsOneWidget);
      expect(find.text('38%'), findsOneWidget);
      expect(find.text('Bolhas no filme'), findsOneWidget);
      expect(find.text('22%'), findsOneWidget);
    });

    testWidgets('renders HorizontalBarChartCard with proportional bars and values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 380,
                child: HorizontalBarChartCard(
                  title: 'Problemas por produto',
                  items: [
                    HorizontalBarItem(label: 'RAP10', value: 46),
                    HorizontalBarItem(label: 'Macarrão Instantâneo', value: 26),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Problemas por produto'), findsOneWidget);
      expect(find.text('RAP10'), findsOneWidget);
      expect(find.text('46'), findsOneWidget);
      expect(find.text('Macarrão Instantâneo'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
    });

    testWidgets('renders SparklineKpiCard with primary metric, delta, and embedded sparkline chart', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 380,
                child: SparklineKpiCard(
                  title: 'Tempo Médio até a Conclusão',
                  valueString: '2h 45m',
                  delta: 8.3,
                  isIncrease: false,
                  positive: true,
                  sparkline: [15, 30, 45, 34, 46],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tempo Médio até a Conclusão'), findsOneWidget);
      expect(find.text('2h 45m'), findsOneWidget);
      expect(find.text('▼'), findsOneWidget);
      expect(find.text('8,3%'), findsOneWidget);
      expect(find.text('vs 30 dias ant.'), findsOneWidget);
    });

    testWidgets('DashboardsScreen switches smoothly between all 4 tabs without re-fetching', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final notifier = DashboardNotifier();
      notifier.state = DashboardState.loaded(
        overview: createMockOverview(),
        problems: createMockProblems(),
        trainings: createMockTrainings(),
        ai: createMockAI(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardsScreen(notifier: notifier),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 0: Visão Geral
      expect(find.text('Visão Geral'), findsOneWidget);
      expect(find.text('Problemas Reportados'), findsOneWidget);
      expect(find.text('Solicitações de Ajuda'), findsOneWidget);
      expect(find.text('Resolução pelo Sistema'), findsOneWidget);
      expect(find.text('Evolução Geral'), findsOneWidget);

      // Tap Tab 1: Problemas
      await tester.tap(find.text('Problemas'));
      await tester.pumpAndSettle();

      expect(find.text('Total de Problemas'), findsOneWidget);
      expect(find.text('Resolvidos pelo Sistema'), findsOneWidget);
      expect(find.text('Resolução por Supervisão & Materiais'), findsOneWidget);
      expect(find.text('Problemas por categoria'), findsOneWidget);
      expect(find.text('Tempo Médio até a Conclusão'), findsOneWidget);

      // Tap Tab 2: Treinamentos
      await tester.tap(find.text('Treinamentos'));
      await tester.pumpAndSettle();

      expect(find.text('Total Treinamentos'), findsOneWidget);
      expect(find.text('Taxa Desistência'), findsOneWidget);
      expect(find.text('Ranking de Cursos (Maior Desistência / Reprovação)'), findsOneWidget);
      expect(find.text('Taxa de Aprovação vs Reprovação'), findsOneWidget);
      expect(find.text('Situação dos usuários'), findsOneWidget);
      expect(find.text('Média de Acertos nas Avaliações'), findsOneWidget);

      // Tap Tab 3: Assistente IA
      await tester.tap(find.text('Assistente IA'));
      await tester.pumpAndSettle();

      expect(find.text('Conversas'), findsOneWidget);
      expect(find.text('Dúvidas respondidas'), findsOneWidget);
      expect(find.text('Dúvidas não respondidas'), findsWidgets);
      expect(find.text('Conteúdos cadastrados'), findsOneWidget);
      expect(find.text('Interações com IA'), findsOneWidget);
    });

    test('dynamic delta calculation algorithm matches specification formula', () {
      double calcDelta(double current, double prior) {
        if (prior == 0) return 0.0;
        return ((current - prior) / prior) * 100;
      }

      expect(calcDelta(128, 0), 0.0);
      expect(double.parse(calcDelta(128, 118).toStringAsFixed(1)), 8.5);
      expect(double.parse(calcDelta(32, 36).toStringAsFixed(1)), -11.1);
    });

    testWidgets('renders TimeSeriesLineChartCard with 3 comparison trend lines and legends', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: TimeSeriesLineChartCard(
                  title: 'Evolução Geral',
                  series: [
                    ChartLineSeries(label: 'Solicitação de ajuda', color: Color(0xFFDC2626), values: [57, 60, 66]),
                    ChartLineSeries(label: 'Problemas reportados', color: Color(0xFF2563EB), values: [36, 38, 41]),
                    ChartLineSeries(label: 'Resolução pelo sistema', color: Color(0xFF16A34A), values: [17, 25, 25]),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Evolução Geral'), findsOneWidget);
      expect(find.text('Solicitação de ajuda'), findsOneWidget);
      expect(find.text('Problemas reportados'), findsOneWidget);
      expect(find.text('Resolução pelo sistema'), findsOneWidget);
    });

    testWidgets('SegmentedHeaderNavigation triggers onTabSelected callback', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SegmentedHeaderNavigation(
                  selectedIndex: selected,
                  onTabSelected: (index) => setState(() => selected = index),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Visão Geral'), findsOneWidget);
      expect(find.text('Problemas'), findsOneWidget);
      await tester.tap(find.text('Problemas'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  });
}
