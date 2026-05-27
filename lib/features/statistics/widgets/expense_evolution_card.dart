import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseEvolutionCard extends StatelessWidget {
  const ExpenseEvolutionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Evolucion de gastos',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.keyboard_arrow_down, size: 22),
                label: const Text('Este mes'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 205,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 29,
                minY: 0,
                maxY: 1000,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 250,
                  getDrawingHorizontalLine: (_) {
                    return const FlLine(
                      color: Color(0xFFE5E7EB),
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
                      interval: 250,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _moneyLabel(value),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
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
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final labels = {
                          1: '1 May',
                          8: '8 May',
                          15: '15 May',
                          22: '22 May',
                          29: '29 May',
                        };

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[value.toInt()] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
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
                    spots: const [
                      FlSpot(1, 170),
                      FlSpot(4, 360),
                      FlSpot(8, 470),
                      FlSpot(11, 550),
                      FlSpot(14, 420),
                      FlSpot(17, 620),
                      FlSpot(20, 730),
                      FlSpot(23, 610),
                      FlSpot(26, 760),
                      FlSpot(29, 930),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.28,
                    color: const Color(0xFF19B86D),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4.5,
                          color: const Color(0xFF19B86D),
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF19B86D).withOpacity(0.26),
                          const Color(0xFF19B86D).withOpacity(0.02),
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

  static String _moneyLabel(double value) {
    if (value == 0) {
      return r'$0';
    }

    if (value == 1000) {
      return r'$1,000';
    }

    return '\$${value.toInt()}';
  }
}
