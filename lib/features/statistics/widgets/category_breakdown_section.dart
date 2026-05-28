import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gastos por categoria',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 26),
        if (items.isEmpty)
          const Text(
            'Registra gastos para ver el desglose.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Row(
            children: [
              Expanded(
                flex: 8,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _DonutChart(items: items),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    for (final item in items) _CategoryLegendRow(item: item),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<_CategoryExpense> _itemsFrom(
    Map<String, double> expenseByCategory,
    List<Category> categories,
  ) {
    const colors = [
      Color(0xFFFF5147),
      Color(0xFF13A982),
      Color(0xFFFF974A),
      Color(0xFF2BA5D6),
      Color(0xFF9278DD),
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
            centerSpaceRadius: 54,
            sectionsSpace: 0,
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
            Text(
              CurrencyFormatter.format(
                items.fold(0.0, (sum, item) => sum + item.amount),
              ),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Total',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: 18),
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
                color: Color(0xFF111827),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.format(item.amount),
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              '${item.percent.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
