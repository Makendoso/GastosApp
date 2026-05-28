import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/providers/finance_providers.dart';

class ExpenseEvolutionCard extends StatelessWidget {
  const ExpenseEvolutionCard({
    required this.points,
    required this.period,
    super.key,
  });

  final List<ExpenseEvolutionPoint> points;
  final StatisticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final hasExpenses = points.any((point) => point.amount > 0);
    final maxAmount = points.fold(0.0, (max, point) {
      return point.amount > max ? point.amount : max;
    });
    final maxY = _chartMaxY(maxAmount);
    final interval = maxY / 4;
    final spots = [
      for (final point in points) FlSpot(point.x.toDouble(), point.amount),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.show_chart, color: AppColors.info),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Evolucion de gastos',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasExpenses)
            _EmptyEvolutionState(period: period)
          else
            SizedBox(
              height: 205,
              child: LineChart(
                LineChartData(
                  minX: 1,
                  maxX: points.last.x.toDouble(),
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (_) {
                      return const FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 46,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _moneyLabel(value),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _labelInterval(period, points.last.x),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 1 || index > points.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              points[index - 1].label,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.24,
                      color: AppColors.info,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: index == spots.length - 1 ? 4.5 : 0,
                            color: AppColors.info,
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.info.withOpacity(0.20),
                            AppColors.info.withOpacity(0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static double _chartMaxY(double value) {
    if (value <= 0) {
      return 100;
    }

    final step = value <= 1000 ? 250 : 1000;
    return ((value / step).ceil() * step).toDouble();
  }

  static double _labelInterval(StatisticsPeriod period, int lastX) {
    if (period == StatisticsPeriod.week) {
      return 1;
    }

    if (period == StatisticsPeriod.year) {
      return 1;
    }

    if (lastX <= 14) {
      return 3;
    }

    return 7;
  }

  static String _moneyLabel(double value) {
    if (value == 0) {
      return r'$0';
    }

    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}k';
    }

    return '\$${value.toInt()}';
  }
}

class _EmptyEvolutionState extends StatelessWidget {
  const _EmptyEvolutionState({required this.period});

  final StatisticsPeriod period;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.show_chart, color: AppColors.textMuted, size: 34),
          const SizedBox(height: AppSpacing.sm),
          Text(
            period.emptyEvolutionTitle,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'La evolucion aparecera cuando registres gastos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
