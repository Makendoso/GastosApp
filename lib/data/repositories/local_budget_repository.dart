import '../models/monthly_budget.dart';
import '../services/budget_data_source.dart';
import 'budget_repository.dart';

class BudgetValidationException implements Exception {
  const BudgetValidationException(this.message);

  final String message;
}

class LocalBudgetRepository implements BudgetRepository {
  const LocalBudgetRepository(this._dataSource);

  final BudgetDataSource _dataSource;

  @override
  Future<MonthlyBudget> getCurrentMonthBudget() {
    return _dataSource.getMonthlyBudget(MonthlyBudget.keyFor(DateTime.now()));
  }

  @override
  Future<void> saveCurrentMonthBudget(double limit) {
    if (limit < 0) {
      throw const BudgetValidationException(
        'El presupuesto no puede ser negativo.',
      );
    }

    return _dataSource.saveMonthlyBudget(
      MonthlyBudget(
        monthKey: MonthlyBudget.keyFor(DateTime.now()),
        limit: limit,
      ),
    );
  }
}
