import 'package:flutter/material.dart';

import '../../features/add_expense/add_expense_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/statistics/statistics_screen.dart';

abstract final class AppRoutes {
  static const addExpense = '/add-expense';
  static const history = '/history';
  static const statistics = '/statistics';

  static Map<String, WidgetBuilder> get routes => {
        addExpense: (_) => const AddExpenseScreen(),
        history: (_) => const HistoryScreen(),
        statistics: (_) => const StatisticsScreen(),
      };
}
