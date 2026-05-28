import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category.dart';

class CategoryExpenseList extends StatelessWidget {
  const CategoryExpenseList({
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

    return Column(
      children: [
        for (final entry in entries)
          _CategoryExpenseRow(
            name: entry.key,
            amount: entry.value,
            percent: total == 0 ? 0 : (entry.value / total) * 100,
            color: _colorFor(entry.key),
          ),
      ],
    );
  }

  Color _colorFor(String categoryName) {
    final category = _categoryFor(categoryName);
    return category?.color ?? Colors.grey;
  }

  Category? _categoryFor(String categoryName) {
    final normalizedName = categoryName.toLowerCase();

    for (final category in categories) {
      if (category.name.toLowerCase() == normalizedName ||
          category.id.toLowerCase() == normalizedName) {
        return category;
      }
    }

    return null;
  }
}

class _CategoryExpenseRow extends StatelessWidget {
  const _CategoryExpenseRow({
    required this.name,
    required this.amount,
    required this.percent,
    required this.color,
  });

  final String name;
  final double amount;
  final double percent;
  final Color color;

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
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
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
                CurrencyFormatter.format(amount),
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
              '${percent.toStringAsFixed(0)}%',
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
