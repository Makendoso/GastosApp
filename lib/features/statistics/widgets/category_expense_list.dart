import 'package:flutter/material.dart';

import '../../../core/formatters/currency_formatter.dart';
import '../../../data/models/finance_category.dart';

class CategoryExpenseList extends StatelessWidget {
  const CategoryExpenseList({
    required this.categories,
    super.key,
  });

  final List<FinanceCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in _amounts.entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              categories[entry.key].icon,
              color: categories[entry.key].color,
            ),
            title: Text(categories[entry.key].name),
            trailing: Text(
              CurrencyFormatter.format(entry.value),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Map<int, double> get _amounts => const {
        0: 4000,
        1: 2500,
        2: 2000,
        3: 1500,
      };
}
