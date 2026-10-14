import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_text_styles/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Shared bar chart that follows the 2026 redesign interaction pattern
/// (Figma "Charts" component — node 229:6957).
///
/// Pattern:
///  * Each column sits on a light **track** (full-height rounded rect, #F5F6F9).
///  * Resting bars are light blue (#AFD3EB).
///  * One column is **selected** — the busiest bar by default, or whichever
///    column the user taps. The selected bar fills with the teal brand gradient
///    and shows a floating blue value label above it.
///
/// Used by every Work-vs-Break / Activity-log chart in the app so the
/// interaction is identical everywhere.
class DsBarChart extends StatefulWidget {
  const DsBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.labelBuilder,
    this.initialSelected,
    this.barWidth = 22,
  });

  /// Bar magnitudes, one per column.
  final List<double> values;

  /// Axis label for each column (e.g. "MON").
  final List<String> labels;

  /// Builds the floating tooltip text for a selected column.
  final String Function(int index, double value) labelBuilder;

  /// Column lit on first build. Defaults to the tallest bar.
  final int? initialSelected;

  /// Width of each value bar.
  final double barWidth;

  @override
  State<DsBarChart> createState() => _DsBarChartState();
}

class _DsBarChartState extends State<DsBarChart> {
  // Resting / selected bar treatment from the Figma spec.
  static const Color _track = Color(0xFFF5F6F9); // Background
  static const Color _rest = Color(0xFFAFD3EB); // light blue
  static const List<Color> _selectedGradient = [
    Color(0xFF71CAC7),
    Color(0xFF4AA8BD),
  ];

  int? _touched; // column the user is actively holding

  int get _selected {
    if (_touched != null) return _touched!;
    if (widget.initialSelected != null) return widget.initialSelected!;
    return _busiestIndex;
  }

  int get _busiestIndex {
    var idx = 0;
    for (var i = 1; i < widget.values.length; i++) {
      if (widget.values[i] > widget.values[idx]) idx = i;
    }
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    final maxVal = widget.values.fold<double>(0, (p, e) => e > p ? e : p);
    // Headroom above the tallest bar so the floating label never clips.
    final maxY = maxVal <= 0 ? 1.0 : maxVal * 1.32;
    final selected = _selected;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.transparent,
            tooltipMargin: 8,
            tooltipPadding: EdgeInsets.zero,
            fitInsideVertically: true,
            fitInsideHorizontally: true,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              widget.labelBuilder(group.x, widget.values[group.x]),
              AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          touchCallback: (event, response) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.spot == null) {
                _touched = null;
              } else {
                _touched = response.spot!.touchedBarGroupIndex;
              }
            });
          },
        ),
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
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= widget.labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.labels[i],
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      letterSpacing: 1.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < widget.values.length; i++)
            BarChartGroupData(
              x: i,
              // Keep the selected bar's floating label visible without an
              // active touch.
              showingTooltipIndicators: i == selected ? [0] : const [],
              barRods: [
                BarChartRodData(
                  // Give empty days a sliver so the rounded cap still reads.
                  toY: widget.values[i] <= 0 ? maxY * 0.06 : widget.values[i],
                  width: widget.barWidth,
                  borderRadius: BorderRadius.circular(widget.barWidth),
                  color: i == selected ? null : _rest,
                  gradient: i == selected
                      ? const LinearGradient(
                          colors: _selectedGradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: _track,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
