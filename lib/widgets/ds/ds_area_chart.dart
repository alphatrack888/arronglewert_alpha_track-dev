import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Shared intraday area chart following the 2026 redesign interaction pattern
/// (Figma "Charts" → Today / On-Press — node 229:6717 / 229:6718).
///
/// Pattern:
///  * A smooth teal area curve plots cumulative worked hours across the day
///    (flat during breaks, rising while working).
///  * Resting state is just the curve — no marker.
///  * On press, a teal dot snaps onto the curve and a floating blue label
///    appears beside it (e.g. "Break" over a break gap, or the worked total
///    elsewhere).
///
/// Sibling to [DsBarChart] so DAY views share the same visual language as the
/// WEEK / MONTH bar charts.
class DsAreaChart extends StatelessWidget {
  const DsAreaChart({
    super.key,
    required this.spots,
    required this.minX,
    required this.maxX,
    required this.hourTicks,
    required this.labelForX,
  });

  /// Curve points: x = hour-of-day (decimal), y = cumulative hours worked.
  final List<FlSpot> spots;

  /// Axis bounds, snapped to whole hours.
  final double minX;
  final double maxX;

  /// Whole-hour ticks to label on the x-axis (e.g. 9, 10, … 16).
  final List<int> hourTicks;

  /// Builds the floating press label for a scrubbed x position.
  final String Function(double x) labelForX;

  // Curve / accent treatment from the Figma spec.
  static const Color _lineTop = Color(0xFF71CAC7);
  static const Color _lineBottom = Color(0xFF4AA8BD);

  @override
  Widget build(BuildContext context) {
    final maxY =
        spots.fold<double>(0, (p, s) => s.y > p ? s.y : p) * 1.25 + 0.01;

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final h = value.round();
                if ((value - h).abs() > 0.01 || !hourTicks.contains(h)) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text(
                    '$h:00',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, indexes) => indexes
              .map(
                (_) => TouchedSpotIndicatorData(
                  // No vertical guide line in the design — just the dot.
                  const FlLine(color: Colors.transparent, strokeWidth: 0),
                  FlDotData(
                    getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                      radius: 7,
                      color: _lineBottom,
                      strokeWidth: 3,
                      strokeColor: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipPadding: EdgeInsets.zero,
            tooltipMargin: 12,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touched) => touched
                .map(
                  (s) => LineTooltipItem(
                    labelForX(s.x),
                    AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            barWidth: 3,
            gradient: const LinearGradient(colors: [_lineTop, _lineBottom]),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _lineBottom.withValues(alpha: 0.28),
                  _lineBottom.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
