import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
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

    return Column(
      children: [
        for (final entry in entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_iconFor(entry.key), color: _colorFor(entry.key)),
            title: Text(entry.key),
            trailing: Text(
              CurrencyFormatter.format(entry.value),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  IconData _iconFor(String categoryName) {
    final category = _categoryFor(categoryName);
    return category?.icon ?? Icons.receipt_long;
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
