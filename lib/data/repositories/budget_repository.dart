import '../models/monthly_budget.dart';

abstract interface class BudgetRepository {
  Future<MonthlyBudget> getCurrentMonthBudget();

  Future<void> saveCurrentMonthBudget(double limit);
}
