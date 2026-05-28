import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
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
    final total = entries.fold(0.0, (sum, entry) => sum + entry.value);

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 50,
            sectionsSpace: 2,
            startDegreeOffset: -90,
            sections: [
              for (final entry in entries)
                PieChartSectionData(
                  color: _colorFor(entry.key),
                  value: total == 0 ? 0 : (entry.value / total) * 100,
                  title: '',
                  radius: 34,
                ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(total),
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Total',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
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
