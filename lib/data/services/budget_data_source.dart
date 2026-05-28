import '../models/monthly_budget.dart';

abstract interface class BudgetDataSource {
  Future<MonthlyBudget> getMonthlyBudget(String monthKey);

  Future<void> saveMonthlyBudget(MonthlyBudget budget);
}
