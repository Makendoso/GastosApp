import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/category.dart';
import '../../../data/models/financial_summary.dart';

class CategoryBreakdownSection extends StatelessWidget {
  const CategoryBreakdownSection({
    required this.summary,
    required this.categories,
    super.key,
  });

  final FinancialSummary summary;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final items = _itemsFrom(summary.expenseByCategory, categories);

    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.donut_small_outlined, color: AppColors.expense),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Gastos por categoria',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (items.isEmpty)
            const _EmptyStatsState()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;

                if (isCompact) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 210,
                        child: _DonutChart(items: items),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _CategoryLegend(items: items),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 8,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _DonutChart(items: items),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 9,
                      child: _CategoryLegend(items: items),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  List<_CategoryExpense> _itemsFrom(
    Map<String, double> expenseByCategory,
    List<Category> categories,
  ) {
    const colors = [
      Color(0xFFDC2626),
      Color(0xFF2563EB),
      Color(0xFFF59E0B),
      Color(0xFF16A34A),
      Color(0xFF7C3AED),
      Color(0xFF64748B),
    ];
    final total = expenseByCategory.values.fold(0.0, (sum, item) => sum + item);
    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return [
      for (var index = 0; index < entries.length; index++)
        _CategoryExpense(
          entries[index].key,
          entries[index].value,
          total == 0 ? 0 : (entries[index].value / total) * 100,
          _colorFor(entries[index].key, categories) ??
              colors[index % colors.length],
        ),
    ];
  }

  Color? _colorFor(String categoryName, List<Category> categories) {
    final normalizedName = categoryName.toLowerCase();

    for (final category in categories) {
      if (category.name.toLowerCase() == normalizedName ||
          category.id.toLowerCase() == normalizedName) {
        return category.color;
      }
    }

    return null;
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.items});

  final List<_CategoryExpense> items;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 50,
            sectionsSpace: 2,
            startDegreeOffset: -90,
            sections: [
              for (final item in items)
                PieChartSectionData(
                  value: item.percent,
                  color: item.color,
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
                CurrencyFormatter.format(
                  items.fold(0.0, (sum, item) => sum + item.amount),
                ),
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
}

class _CategoryLegend extends StatelessWidget {
  const _CategoryLegend({required this.items});

  final List<_CategoryExpense> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) _CategoryLegendRow(item: item),
      ],
    );
  }
}

class _CategoryLegendRow extends StatelessWidget {
  const _CategoryLegendRow({required this.item});

  final _CategoryExpense item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                CurrencyFormatter.format(item.amount),
                maxLines: 1,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 34,
            child: Text(
              '${item.percent.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStatsState extends StatelessWidget {
  const _EmptyStatsState();

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
      child: const Column(
        children: [
          Icon(Icons.bar_chart_outlined, color: AppColors.textMuted, size: 34),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sin estadisticas todavia',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Registra gastos para ver el desglose por categoria.',
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

class _CategoryExpense {
  const _CategoryExpense(this.name, this.amount, this.percent, this.color);

  final String name;
  final double amount;
  final double percent;
  final Color color;
}
