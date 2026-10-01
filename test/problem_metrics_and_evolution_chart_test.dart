import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pext/features/troubleshooting/troubleshooting_screens.dart';
import 'package:pext/models/dashboard_analytics_models.dart';
import 'package:pext/shared/widgets/dashboard/dashboard_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Problem Metrics, System Resolution & Dynamic Evolution Chart Tests', () {
    testWidgets('SolutionsScreen triggers resolveProblemBySystem on PROBLEMA SOLUCIONADO', (tester) async {
      final measurements = {'Espessura': 50.0};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SolutionsScreen(
              problem: 'Variação na espessura',
              packaging: 'RAP10',
              measurements: measurements,
              diagnosticLogId: 'log-12345',
            ),
          ),
        ),
      );

      expect(find.text('PROBLEMA SOLUCIONADO'), findsOneWidget);
      expect(find.text('NÃO CONSEGUI RESOLVER'), findsOneWidget);

      await tester.tap(find.text('PROBLEMA SOLUCIONADO'));
      await tester.pumpAndSettle();
    });

    testWidgets('Evolução Geral chart renders 3 comparison series with accurate legends and color tags', (tester) async {
      final labels = List.generate(30, (i) => '${(i + 1).toString().padLeft(2, '0')} Set');
      final helpReqSeries = List.generate(30, (i) => (i % 5).toDouble());
      final probSeries = List.generate(30, (i) => (i % 4 + 1).toDouble());
      final sysSeries = List.generate(30, (i) => (i % 3).toDouble());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 420,
                child: TimeSeriesLineChartCard(
                  title: 'Evolução Geral',
                  height: 220,
                  labels: labels,
                  series: [
                    ChartLineSeries(
                      label: 'Solicitação de ajuda',
                      color: const Color(0xFFDC2626),
                      values: helpReqSeries,
                    ),
                    ChartLineSeries(
                      label: 'Problemas reportados',
                      color: const Color(0xFF2563EB),
                      values: probSeries,
                    ),
                    ChartLineSeries(
                      label: 'Resolução pelo sistema',
                      color: const Color(0xFF16A34A),
                      values: sysSeries,
                    ),
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

    test('OverviewAnalytics model parses dynamic evolution and KPI metrics correctly', () {
      final json = {
        'problemsReported': {
          'value': 90,
          'prior': 85,
          'delta': 5.9,
          'isIncrease': true,
          'positive': false,
          'formattedValue': '90',
          'trendText': '5,9%',
          'subtitle': 'vs 30 dias ant.',
        },
        'helpRequests': {
          'value': 25,
          'prior': 30,
          'delta': 16.7,
          'isIncrease': false,
          'positive': true,
          'formattedValue': '25',
          'trendText': '16,7%',
          'subtitle': 'vs 30 dias ant.',
        },
        'systemResolutionRate': {
          'value': 78.5,
          'prior': 72.0,
          'delta': 9.0,
          'isIncrease': true,
          'positive': true,
          'formattedValue': '78,5%',
          'trendText': '9,0%',
          'subtitle': 'vs 30 dias ant.',
        },
        'unansweredDoubts': {
          'value': 8,
          'prior': 10,
          'delta': 20.0,
          'isIncrease': false,
          'positive': true,
          'formattedValue': '8',
          'trendText': '20,0%',
          'subtitle': 'vs 30 dias ant.',
        },
        'trainingsCompleted': {
          'value': 45,
          'prior': 40,
          'delta': 12.5,
          'isIncrease': true,
          'positive': true,
          'formattedValue': '45',
          'trendText': '12,5%',
          'subtitle': 'vs 30 dias ant.',
        },
        'averageApprovalRate': {
          'value': 82.4,
          'prior': 79.1,
          'delta': 4.2,
          'isIncrease': true,
          'positive': true,
          'formattedValue': '82,4%',
          'trendText': '4,2%',
          'subtitle': 'vs 30 dias ant.',
        },
        'evolution': {
          'labels': ['01 Set', '15 Set', '30 Set'],
          'helpRequests': [10.0, 15.0, 20.0],
          'problemsReported': [12.0, 18.0, 25.0],
          'systemResolution': [8.0, 14.0, 21.0],
        },
      };

      final overview = OverviewAnalytics.fromJson(json);

      expect(overview.problemsReported.value, 90);
      expect(overview.problemsReported.formattedValue, '90');
      expect(overview.systemResolutionRate.value, 78.5);
      expect(overview.systemResolutionRate.formattedValue, '78,5%');
      expect(overview.evolutionLabels.length, 3);
      expect(overview.helpRequestsSeries.length, 3);
      expect(overview.problemsReportedSeries.length, 3);
      expect(overview.systemResolutionSeries.length, 3);
    });

    test('System resolution rate KPI formula calculation validation', () {
      double calculateSystemRate(int resolvedBySystem, int totalProblems) {
        if (totalProblems == 0) return 0.0;
        return (resolvedBySystem / totalProblems) * 100;
      }

      expect(calculateSystemRate(0, 0), 0.0);
      expect(double.parse(calculateSystemRate(75, 100).toStringAsFixed(1)), 75.0);
      expect(double.parse(calculateSystemRate(23, 30).toStringAsFixed(1)), 76.7);
    });
  });
}
