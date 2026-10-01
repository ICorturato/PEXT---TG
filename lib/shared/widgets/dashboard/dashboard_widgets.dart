import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/dashboard_analytics_models.dart';

class SegmentedHeaderNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> tabs;

  const SegmentedHeaderNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.tabs = const [
      'Visão Geral',
      'Problemas',
      'Treinamentos',
      'Assistente IA',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 8),
            child: InkWell(
              onTap: () => onTabSelected(index),
              borderRadius: BorderRadius.circular(24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF132B5C) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF132B5C) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class KpiCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final String? formattedValue;
  final double delta;
  final bool isIncrease;
  final bool positive;
  final String subtitle;
  final Color? titleColor;
  final bool compact;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.formattedValue,
    this.delta = 0.0,
    this.isIncrease = true,
    this.positive = true,
    this.subtitle = 'vs 30 dias ant.',
    this.titleColor,
    this.compact = false,
  });

  factory KpiCard.fromMetric({
    Key? key,
    required String title,
    required KpiMetric metric,
    bool compact = false,
    Color? overrideTitleColor,
  }) {
    return KpiCard(
      key: key,
      title: title,
      value: metric.value,
      formattedValue: metric.formattedValue,
      delta: metric.delta,
      isIncrease: metric.isIncrease,
      positive: metric.positive,
      subtitle: metric.subtitle,
      titleColor: overrideTitleColor ?? metric.titleColor,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayVal = formattedValue ?? '$value';
    final trendColor = positive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: titleColor ?? const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayVal,
            style: TextStyle(
              fontSize: compact ? 26 : 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                isIncrease ? '▲' : '▼',
                style: TextStyle(
                  fontSize: 10,
                  color: trendColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                '${delta.toStringAsFixed(1).replaceAll('.', ',')}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: trendColor,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonutChartCard extends StatelessWidget {
  final String? title;
  final List<DonutSliceData> slices;
  final double centerSpaceRadius;
  final double sectionsSpace;

  const DonutChartCard({
    super.key,
    this.title,
    required this.slices,
    this.centerSpaceRadius = 40,
    this.sectionsSpace = 2,
  });

  @override
  Widget build(BuildContext context) {
    final validSlices = slices.isEmpty
        ? const [DonutSliceData(label: 'Sem dados', percentage: 100, color: Color(0xFFCBD5E1))]
        : slices;

    final pieSections = validSlices.map((slice) {
      return PieChartSectionData(
        value: slice.percentage <= 0 ? 0.1 : slice.percentage,
        color: slice.color,
        radius: 18,
        showTitle: false,
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF132B5C),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: centerSpaceRadius,
                    sectionsSpace: sectionsSpace,
                    sections: pieSections,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: validSlices.map((slice) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: slice.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              slice.label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${slice.percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HorizontalBarChartCard extends StatelessWidget {
  final String? title;
  final List<HorizontalBarItem> items;
  final String valueSuffix;
  final Color barColor;

  const HorizontalBarChartCard({
    super.key,
    this.title,
    required this.items,
    this.valueSuffix = '',
    this.barColor = const Color(0xFF132B5C),
  });

  @override
  Widget build(BuildContext context) {
    final highest = items.fold<double>(
      0.0,
      (max, item) => item.value > max ? item.value : max,
    );
    final maxScale = highest > 0 ? highest : 100.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF132B5C),
              ),
            ),
            const SizedBox(height: 14),
          ],
          ...items.map((item) {
            final ratio = (item.value / maxScale).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        color: barColor,
                        backgroundColor: const Color(0xFFF1F5F9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 36,
                    child: Text(
                      item.valueFormatted ?? '${item.value.toInt()}$valueSuffix',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ChartLineSeries {
  final String label;
  final Color color;
  final List<double> values;

  const ChartLineSeries({
    required this.label,
    required this.color,
    required this.values,
  });
}

class TimeSeriesLineChartCard extends StatelessWidget {
  final String? title;
  final List<ChartLineSeries> series;
  final List<String> labels;
  final double height;

  const TimeSeriesLineChartCard({
    super.key,
    this.title,
    required this.series,
    this.labels = const [],
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    double highestVal = 0.0;
    for (final s in series) {
      for (final v in s.values) {
        if (v > highestVal) highestVal = v;
      }
    }
    final maxY = highestVal > 0 ? (highestVal * 1.2).ceilToDouble() : 5.0;

    final lineBars = series.map((s) {
      final spots = <FlSpot>[];
      for (var i = 0; i < s.values.length; i++) {
        spots.add(FlSpot(i.toDouble(), s.values[i]));
      }
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.35,
        color: s.color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 3,
              color: s.color,
              strokeWidth: 0,
            );
          },
        ),
      );
    }).toList();

    final count = series.isNotEmpty && series.first.values.isNotEmpty
        ? series.first.values.length
        : labels.length;
    final interval = count > 10 ? (count / 5).floorToDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF132B5C),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (series.length > 1) ...[
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: series.map((s) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: series.isEmpty || series.first.values.isEmpty
                    ? 1
                    : (series.first.values.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: labels.isNotEmpty,
                      reservedSize: 22,
                      interval: interval > 0 ? interval : 1.0,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[idx],
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: lineBars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SparklineKpiCard extends StatelessWidget {
  final String title;
  final String valueString;
  final double delta;
  final bool isIncrease;
  final bool positive;
  final String subtitle;
  final List<double> sparkline;
  final Color sparklineColor;

  const SparklineKpiCard({
    super.key,
    required this.title,
    required this.valueString,
    this.delta = 0.0,
    this.isIncrease = true,
    this.positive = true,
    this.subtitle = 'vs 30 dias ant.',
    required this.sparkline,
    this.sparklineColor = const Color(0xFF2563EB),
  });

  factory SparklineKpiCard.fromMetric({
    Key? key,
    required String title,
    required SparklineMetric metric,
    Color sparklineColor = const Color(0xFF2563EB),
  }) {
    return SparklineKpiCard(
      key: key,
      title: title,
      valueString: metric.valueString,
      delta: metric.delta,
      isIncrease: metric.isIncrease,
      positive: metric.positive,
      subtitle: metric.subtitle,
      sparkline: metric.sparkline,
      sparklineColor: sparklineColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trendColor = positive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    double minY = 0.0;
    double maxY = 10.0;
    if (sparkline.isNotEmpty) {
      minY = sparkline.reduce((min, val) => val < min ? val : min);
      maxY = sparkline.reduce((max, val) => val > max ? val : max);
      if (minY == maxY) {
        minY = 0;
        maxY *= 1.5;
      }
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < sparkline.length; i++) {
      spots.add(FlSpot(i.toDouble(), sparkline[i]));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF132B5C),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueString,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isIncrease ? '▲' : '▼',
                              style: TextStyle(
                                fontSize: 10,
                                color: trendColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${delta.toStringAsFixed(1).replaceAll('.', ',')}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: trendColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 64,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: sparkline.isEmpty ? 1 : (sparkline.length - 1).toDouble(),
                      minY: minY * 0.9,
                      maxY: maxY * 1.1,
                      titlesData: const FlTitlesData(show: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: sparklineColor,
                          barWidth: 2.0,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
