import 'package:flutter/material.dart';

class KpiMetric {
  final dynamic value;
  final double delta;
  final bool isIncrease;
  final bool positive;
  final String formattedValue;
  final String trendText;
  final String subtitle;
  final Color? titleColor;

  const KpiMetric({
    required this.value,
    required this.delta,
    required this.isIncrease,
    required this.positive,
    required this.formattedValue,
    required this.trendText,
    this.subtitle = 'vs 30 dias ant.',
    this.titleColor,
  });

  factory KpiMetric.fromJson(Map<String, dynamic>? json, {dynamic defaultValue = 0, String suffix = '', Color? titleColor}) {
    if (json == null) {
      return KpiMetric(
        value: defaultValue,
        delta: 0.0,
        isIncrease: true,
        positive: true,
        formattedValue: '$defaultValue$suffix',
        trendText: '0,0%',
        subtitle: 'vs 30 dias ant.',
        titleColor: titleColor,
      );
    }
    final rawVal = json['value'] ?? defaultValue;
    final deltaNum = (json['delta'] as num?)?.toDouble() ?? 0.0;
    final isIncreaseVal = json['isIncrease'] as bool? ?? (deltaNum >= 0);
    final positiveVal = json['positive'] as bool? ?? (deltaNum >= 0);
    final formattedVal = json['formattedValue']?.toString() ?? '$rawVal$suffix';
    final trend = json['trendText']?.toString() ?? '${deltaNum.abs().toStringAsFixed(1).replaceAll('.', ',')}%';
    final sub = json['subtitle']?.toString() ?? 'vs 30 dias ant.';

    return KpiMetric(
      value: rawVal,
      delta: deltaNum.abs(),
      isIncrease: isIncreaseVal,
      positive: positiveVal,
      formattedValue: formattedVal,
      trendText: trend,
      subtitle: sub,
      titleColor: titleColor,
    );
  }

  factory KpiMetric.simple({
    required dynamic value,
    double delta = 0.0,
    bool isIncrease = true,
    bool positive = true,
    String suffix = '',
    String subtitle = 'vs 30 dias ant.',
    Color? titleColor,
  }) {
    return KpiMetric(
      value: value,
      delta: delta.abs(),
      isIncrease: isIncrease,
      positive: positive,
      formattedValue: '$value$suffix',
      trendText: '${delta.abs().toStringAsFixed(1).replaceAll('.', ',')}%',
      subtitle: subtitle,
      titleColor: titleColor,
    );
  }
}

class DonutSliceData {
  final String label;
  final double percentage;
  final Color color;

  const DonutSliceData({
    required this.label,
    required this.percentage,
    required this.color,
  });

  factory DonutSliceData.fromJson(Map<String, dynamic> json) {
    final labelStr = json['label']?.toString() ?? json['name']?.toString() ?? '';
    final pct = (json['percentage'] as num?)?.toDouble() ?? 0.0;
    final colorHex = json['color']?.toString() ?? '#2563EB';
    return DonutSliceData(
      label: labelStr,
      percentage: pct,
      color: _parseHexColor(colorHex),
    );
  }
}

class HorizontalBarItem {
  final String label;
  final double value;
  final String? valueFormatted;

  const HorizontalBarItem({
    required this.label,
    required this.value,
    this.valueFormatted,
  });

  factory HorizontalBarItem.fromJson(Map<String, dynamic> json, {String suffix = ''}) {
    final lbl = json['name']?.toString() ?? json['label']?.toString() ?? '';
    final val = (json['count'] as num?)?.toDouble() ??
        (json['percentage'] as num?)?.toDouble() ??
        (json['value'] as num?)?.toDouble() ??
        0.0;
    final formatted = json['valueFormatted']?.toString() ??
        (suffix.isNotEmpty ? '${val.toInt()}$suffix' : '${val.toInt()}');
    return HorizontalBarItem(
      label: lbl,
      value: val,
      valueFormatted: formatted,
    );
  }
}

class SparklineMetric {
  final String valueString;
  final double delta;
  final bool isIncrease;
  final bool positive;
  final String subtitle;
  final List<double> sparkline;

  const SparklineMetric({
    required this.valueString,
    required this.delta,
    required this.isIncrease,
    required this.positive,
    this.subtitle = 'vs 30 dias ant.',
    required this.sparkline,
  });

  factory SparklineMetric.fromJson(Map<String, dynamic>? json, {String defaultVal = '0', List<double>? defaultSparkline}) {
    if (json == null) {
      return SparklineMetric(
        valueString: defaultVal,
        delta: 0.0,
        isIncrease: true,
        positive: true,
        subtitle: 'vs 30 dias ant.',
        sparkline: defaultSparkline ?? const [10, 20, 15, 30, 25, 40],
      );
    }
    final valStr = json['valueString']?.toString() ?? defaultVal;
    final deltaNum = (json['delta'] as num?)?.toDouble() ?? 0.0;
    final isInc = json['isIncrease'] as bool? ?? (deltaNum >= 0);
    final pos = json['positive'] as bool? ?? (deltaNum >= 0);
    final sub = json['subtitle']?.toString() ?? 'vs 30 dias ant.';
    final rawList = json['sparkline'] as List? ?? defaultSparkline ?? const [10, 20, 15, 30, 25, 40];
    final spark = rawList.map((e) => (e as num).toDouble()).toList();

    return SparklineMetric(
      valueString: valStr,
      delta: deltaNum.abs(),
      isIncrease: isInc,
      positive: pos,
      subtitle: sub,
      sparkline: spark,
    );
  }
}

class OverviewAnalytics {
  final KpiMetric problemsReported;
  final KpiMetric helpRequests;
  final KpiMetric systemResolutionRate;
  final KpiMetric unansweredDoubts;
  final KpiMetric trainingsCompleted;
  final KpiMetric averageApprovalRate;
  final List<String> evolutionLabels;
  final List<double> helpRequestsSeries;
  final List<double> problemsReportedSeries;
  final List<double> systemResolutionSeries;

  const OverviewAnalytics({
    required this.problemsReported,
    required this.helpRequests,
    required this.systemResolutionRate,
    required this.unansweredDoubts,
    required this.trainingsCompleted,
    required this.averageApprovalRate,
    required this.evolutionLabels,
    required this.helpRequestsSeries,
    required this.problemsReportedSeries,
    required this.systemResolutionSeries,
  });

  factory OverviewAnalytics.fromJson(Map<String, dynamic> json) {
    final evo = json['evolution'] as Map<String, dynamic>? ?? {};
    final labels = (evo['labels'] as List?)?.map((e) => e.toString()).toList() ??
        ['01 Ago', '04 Ago', '07 Ago', '10 Ago', '13 Ago', '16 Ago', '19 Ago', '22 Ago', '25 Ago', '28 Ago', '30 Ago'];
    final helpSeries = (evo['helpRequests'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        [57, 61, 55, 60, 56, 59, 73, 65, 62, 73, 66];
    final probSeries = (evo['problemsReported'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        [36, 36, 30, 34, 38, 40, 50, 44, 33, 45, 41];
    final sysSeries = (evo['systemResolution'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
        [17, 25, 26, 26, 25, 28, 34, 28, 31, 28, 25];

    return OverviewAnalytics(
      problemsReported: KpiMetric.fromJson(
        json['problemsReported'] as Map<String, dynamic>?,
        defaultValue: 128,
        titleColor: const Color(0xFF0B4AA0),
      ),
      helpRequests: KpiMetric.fromJson(
        json['helpRequests'] as Map<String, dynamic>?,
        defaultValue: 32,
        titleColor: const Color(0xFFDC2626),
      ),
      systemResolutionRate: KpiMetric.fromJson(
        json['systemResolutionRate'] as Map<String, dynamic>?,
        defaultValue: 75.8,
        suffix: '%',
        titleColor: const Color(0xFF16A34A),
      ),
      unansweredDoubts: KpiMetric.fromJson(
        json['unansweredDoubts'] as Map<String, dynamic>?,
        defaultValue: 13,
        titleColor: const Color(0xFFEAB308),
      ),
      trainingsCompleted: KpiMetric.fromJson(
        json['trainingsCompleted'] as Map<String, dynamic>?,
        defaultValue: 36,
        titleColor: const Color(0xFF8B5CF6),
      ),
      averageApprovalRate: KpiMetric.fromJson(
        json['averageApprovalRate'] as Map<String, dynamic>?,
        defaultValue: 78.3,
        suffix: '%',
        titleColor: const Color(0xFF0284C7),
      ),
      evolutionLabels: labels,
      helpRequestsSeries: helpSeries,
      problemsReportedSeries: probSeries,
      systemResolutionSeries: sysSeries,
    );
  }
}

class ProblemsAnalytics {
  final KpiMetric totalProblems;
  final KpiMetric resolvedBySystem;
  final KpiMetric forwardedToAdmin;
  final KpiMetric supervisorResolutionRate;
  final KpiMetric totalMaterials;
  final List<DonutSliceData> problemsByCategory;
  final List<HorizontalBarItem> problemsByProduct;
  final List<double> problemsOverTime;
  final KpiMetric requestsTotal;
  final KpiMetric requestsNew;
  final KpiMetric requestsInProgress;
  final KpiMetric requestsResolved;
  final List<DonutSliceData> requestsByStatus;
  final SparklineMetric averageResolutionTime;
  final List<HorizontalBarItem> topEscalatedProblems;
  final KpiMetric solutionsDisplayed;
  final KpiMetric solutionsSuccessRate;
  final List<HorizontalBarItem> solutionsByType;

  const ProblemsAnalytics({
    required this.totalProblems,
    required this.resolvedBySystem,
    required this.forwardedToAdmin,
    required this.supervisorResolutionRate,
    required this.totalMaterials,
    required this.problemsByCategory,
    required this.problemsByProduct,
    required this.problemsOverTime,
    required this.requestsTotal,
    required this.requestsNew,
    required this.requestsInProgress,
    required this.requestsResolved,
    required this.requestsByStatus,
    required this.averageResolutionTime,
    required this.topEscalatedProblems,
    required this.solutionsDisplayed,
    required this.solutionsSuccessRate,
    required this.solutionsByType,
  });

  factory ProblemsAnalytics.fromJson(Map<String, dynamic> json) {
    final catList = (json['problemsByCategory'] as List?)
            ?.map((e) => DonutSliceData.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          DonutSliceData(label: 'Variação na espessura', percentage: 38, color: Color(0xFF1768DF)),
          DonutSliceData(label: 'Bolhas no filme', percentage: 22, color: Color(0xFF4AA5ED)),
          DonutSliceData(label: 'Marcas de gel', percentage: 15, color: Color(0xFFFFC107)),
          DonutSliceData(label: 'Linhas na superfície', percentage: 10, color: Color(0xFFDC2626)),
          DonutSliceData(label: 'Fusão irregular', percentage: 8, color: Color(0xFF9564E8)),
          DonutSliceData(label: 'Outros', percentage: 7, color: Color(0xFF16A34A)),
        ];

    final prodList = (json['problemsByProduct'] as List?)
            ?.map((e) => HorizontalBarItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          HorizontalBarItem(label: 'RAP10', value: 46),
          HorizontalBarItem(label: 'Macarrão Instantâneo', value: 26),
          HorizontalBarItem(label: 'Marcas de gel', value: 15),
          HorizontalBarItem(label: 'Iorgute', value: 32),
          HorizontalBarItem(label: 'Saco Pão Pulma', value: 63),
        ];

    final timeSeries = (json['problemsOverTime'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [16, 39, 30, 33, 43, 23, 40, 54, 24, 38, 49, 47];

    final reqMap = json['requests'] as Map<String, dynamic>? ?? {};
    final statusList = (json['requestsByStatus'] as List?)
            ?.map((e) => DonutSliceData.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          DonutSliceData(label: 'Novas', percentage: 25, color: Color(0xFF2563EB)),
          DonutSliceData(label: 'Em andamento', percentage: 50, color: Color(0xFF16A34A)),
          DonutSliceData(label: 'Concluídas', percentage: 25, color: Color(0xFFEAB308)),
        ];

    final topEscalated = (json['topEscalatedProblems'] as List?)
            ?.map((e) => HorizontalBarItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          HorizontalBarItem(label: 'Variação na espessura', value: 46),
          HorizontalBarItem(label: 'Bolhas no filme', value: 20),
          HorizontalBarItem(label: 'Marcas de gel', value: 15),
          HorizontalBarItem(label: 'Linhas na superfície do filme', value: 32),
          HorizontalBarItem(label: 'Fusão irregular do filme', value: 63),
        ];

    final solMap = json['solutions'] as Map<String, dynamic>? ?? {};
    final solTypes = (solMap['byType'] as List?)
            ?.map((e) => HorizontalBarItem.fromJson(Map<String, dynamic>.from(e as Map), suffix: '%'))
            .toList() ??
        const [
          HorizontalBarItem(label: 'Ajuste na Temperatura', value: 92, valueFormatted: '92%'),
          HorizontalBarItem(label: 'Ajuste de velocidade', value: 82, valueFormatted: '82%'),
          HorizontalBarItem(label: 'Verificar Resfriamento', value: 80, valueFormatted: '80%'),
          HorizontalBarItem(label: 'Ajuste na Composição', value: 70, valueFormatted: '70%'),
          HorizontalBarItem(label: 'Limpeza de Matriz', value: 62, valueFormatted: '62%'),
        ];

    return ProblemsAnalytics(
      totalProblems: KpiMetric.fromJson(json['totalProblems'] as Map<String, dynamic>?, defaultValue: 128, titleColor: const Color(0xFF0B4AA0)),
      resolvedBySystem: KpiMetric.fromJson(json['resolvedBySystem'] as Map<String, dynamic>?, defaultValue: 97, titleColor: const Color(0xFF16A34A)),
      forwardedToAdmin: KpiMetric.fromJson(json['forwardedToAdmin'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFFDC2626)),
      supervisorResolutionRate: KpiMetric.fromJson(json['supervisorResolutionRate'] as Map<String, dynamic>?, defaultValue: 84.2, suffix: '%', titleColor: const Color(0xFF0B4AA0)),
      totalMaterials: KpiMetric.fromJson(json['totalMaterials'] as Map<String, dynamic>?, defaultValue: 42, titleColor: const Color(0xFF16A34A)),
      problemsByCategory: catList,
      problemsByProduct: prodList,
      problemsOverTime: timeSeries,
      requestsTotal: KpiMetric.fromJson(reqMap['total'] as Map<String, dynamic>?, defaultValue: 128, titleColor: const Color(0xFF0B4AA0)),
      requestsNew: KpiMetric.fromJson(reqMap['new'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFF2563EB)),
      requestsInProgress: KpiMetric.fromJson(reqMap['inProgress'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFFEAB308)),
      requestsResolved: KpiMetric.fromJson(reqMap['resolved'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFF16A34A)),
      requestsByStatus: statusList,
      averageResolutionTime: SparklineMetric.fromJson(
        json['averageResolutionTime'] as Map<String, dynamic>?,
        defaultVal: '2h 45m',
        defaultSparkline: const [15, 30, 45, 34, 37, 35, 56, 46],
      ),
      topEscalatedProblems: topEscalated,
      solutionsDisplayed: KpiMetric.fromJson(solMap['displayed'] as Map<String, dynamic>?, defaultValue: 128, titleColor: const Color(0xFF0B4AA0)),
      solutionsSuccessRate: KpiMetric.fromJson(solMap['successRate'] as Map<String, dynamic>?, defaultValue: 82.3, suffix: '%', titleColor: const Color(0xFF16A34A)),
      solutionsByType: solTypes,
    );
  }
}

class TrainingAnalytics {
  final KpiMetric totalTrainings;
  final KpiMetric inProgress;
  final KpiMetric completed;
  final KpiMetric dropoutRate;
  final List<HorizontalBarItem> courseRankings;
  final List<DonutSliceData> approvalVsFailure;
  final List<DonutSliceData> userStatus;
  final SparklineMetric averageAssessmentScore;

  const TrainingAnalytics({
    required this.totalTrainings,
    required this.inProgress,
    required this.completed,
    required this.dropoutRate,
    required this.courseRankings,
    required this.approvalVsFailure,
    required this.userStatus,
    required this.averageAssessmentScore,
  });

  factory TrainingAnalytics.fromJson(Map<String, dynamic> json) {
    final rankList = (json['courseRankings'] as List?)
            ?.map((e) => HorizontalBarItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          HorizontalBarItem(label: 'Processo de extrusão', value: 38),
          HorizontalBarItem(label: 'Segurança Operacional', value: 26),
          HorizontalBarItem(label: 'Boas Práticas de Produção', value: 18),
          HorizontalBarItem(label: 'Controle Térmico', value: 12),
          HorizontalBarItem(label: 'Regulagem de Matriz', value: 8),
        ];

    final appFailList = (json['approvalVsFailure'] as List?)
            ?.map((e) => DonutSliceData.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          DonutSliceData(label: 'Aprovados', percentage: 79, color: Color(0xFF16A34A)),
          DonutSliceData(label: 'Reprovados', percentage: 21, color: Color(0xFFDC2626)),
        ];

    final uStatList = (json['userStatus'] as List?)
            ?.map((e) => DonutSliceData.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          DonutSliceData(label: 'Concluídos', percentage: 45, color: Color(0xFF2563EB)),
          DonutSliceData(label: 'Em andamento', percentage: 30, color: Color(0xFF16A34A)),
          DonutSliceData(label: 'Não iniciados', percentage: 25, color: Color(0xFFEAB308)),
        ];

    return TrainingAnalytics(
      totalTrainings: KpiMetric.fromJson(json['totalTrainings'] as Map<String, dynamic>?, defaultValue: 128, titleColor: const Color(0xFF0B4AA0)),
      inProgress: KpiMetric.fromJson(json['inProgress'] as Map<String, dynamic>?, defaultValue: 97, titleColor: const Color(0xFFEAB308)),
      completed: KpiMetric.fromJson(json['completed'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFF16A34A)),
      dropoutRate: KpiMetric.fromJson(json['dropoutRate'] as Map<String, dynamic>?, defaultValue: 12.5, suffix: '%', titleColor: const Color(0xFFDC2626)),
      courseRankings: rankList,
      approvalVsFailure: appFailList,
      userStatus: uStatList,
      averageAssessmentScore: SparklineMetric.fromJson(
        json['averageAssessmentScore'] as Map<String, dynamic>?,
        defaultVal: '76,6%',
        defaultSparkline: const [25, 52, 76, 49, 63, 90, 58],
      ),
    );
  }
}

class AIAnalytics {
  final KpiMetric conversations;
  final KpiMetric answeredDoubts;
  final KpiMetric unansweredDoubts;
  final List<HorizontalBarItem> unansweredByTopic;
  final KpiMetric contentsTotal;
  final KpiMetric contentsUpdated;
  final KpiMetric contentsNew;
  final List<double> aiInteractionsOverTime;

  const AIAnalytics({
    required this.conversations,
    required this.answeredDoubts,
    required this.unansweredDoubts,
    required this.unansweredByTopic,
    required this.contentsTotal,
    required this.contentsUpdated,
    required this.contentsNew,
    required this.aiInteractionsOverTime,
  });

  factory AIAnalytics.fromJson(Map<String, dynamic> json) {
    final topicList = (json['unansweredByTopic'] as List?)
            ?.map((e) => HorizontalBarItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const [
          HorizontalBarItem(label: 'Polímeros', value: 46),
          HorizontalBarItem(label: 'Matriz', value: 26),
          HorizontalBarItem(label: 'Processo de Extrusão', value: 15),
          HorizontalBarItem(label: 'Resfriamento', value: 32),
          HorizontalBarItem(label: 'Outros', value: 63),
        ];

    final contMap = json['contents'] as Map<String, dynamic>? ?? {};
    final aiOverTime = (json['aiInteractionsOverTime'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        const [35, 36, 64, 61, 76, 68, 60, 95, 89, 105, 100, 118, 128];

    return AIAnalytics(
      conversations: KpiMetric.fromJson(json['conversations'] as Map<String, dynamic>?, defaultValue: 256, titleColor: const Color(0xFF0B4AA0)),
      answeredDoubts: KpiMetric.fromJson(json['answeredDoubts'] as Map<String, dynamic>?, defaultValue: 97, titleColor: const Color(0xFF16A34A)),
      unansweredDoubts: KpiMetric.fromJson(json['unansweredDoubts'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFFDC2626)),
      unansweredByTopic: topicList,
      contentsTotal: KpiMetric.fromJson(contMap['total'] as Map<String, dynamic>?, defaultValue: 256, titleColor: const Color(0xFF0B4AA0)),
      contentsUpdated: KpiMetric.fromJson(contMap['updated'] as Map<String, dynamic>?, defaultValue: 97, titleColor: const Color(0xFF16A34A)),
      contentsNew: KpiMetric.fromJson(contMap['new'] as Map<String, dynamic>?, defaultValue: 32, titleColor: const Color(0xFFDC2626)),
      aiInteractionsOverTime: aiOverTime,
    );
  }
}

Color _parseHexColor(String hex) {
  final cleanHex = hex.replaceFirst('#', '');
  if (cleanHex.length == 6) {
    return Color(int.parse('0xFF$cleanHex'));
  } else if (cleanHex.length == 8) {
    return Color(int.parse('0x$cleanHex'));
  }
  return const Color(0xFF2563EB);
}
