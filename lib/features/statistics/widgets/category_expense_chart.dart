import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/category.dart';

class CategoryExpenseChart extends StatelessWidget {
  const CategoryExpenseChart({
    required this.categories,
    required this.expenseByCategory,
    super.key,
  });

  final List<Category> categories;
  final Map<String, double> expenseByCategory;

  @override
  Widget build(BuildContext context) {
    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 34,
          sectionsSpace: 3,
          sections: [
            for (final entry in entries)
              PieChartSectionData(
                color: _colorFor(entry.key),
                value: entry.value,
                title: entry.key,
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

  Color _colorFor(String categoryName) {
    final normalizedName = categoryName.toLowerCase();

    for (final category in categories) {
      if (category.name.toLowerCase() == normalizedName ||
          category.id.toLowerCase() == normalizedName) {
        return category.color;
      }
    }

    return Colors.grey;
  }
}
