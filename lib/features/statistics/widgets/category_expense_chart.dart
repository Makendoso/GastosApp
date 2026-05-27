import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/finance_category.dart';

class CategoryExpenseChart extends StatelessWidget {
  const CategoryExpenseChart({
    required this.categories,
    super.key,
  });

  final List<FinanceCategory> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 34,
          sectionsSpace: 3,
          sections: [
            for (final entry in _values.entries)
              PieChartSectionData(
                color: categories[entry.key].color,
                value: entry.value,
                title: categories[entry.key].name,
                radius: 70,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<int, double> get _values => const {
        0: 40,
        1: 25,
        2: 20,
        3: 15,
      };
}
