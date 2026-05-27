import '../models/financial_summary.dart';
import '../models/movement.dart';
import '../services/finance_calculator.dart';
import '../services/finance_data_source.dart';
import 'finance_repository.dart';

class LocalFinanceRepository implements FinanceRepository {
  const LocalFinanceRepository(
    this._dataSource, {
    this.calculator = const FinanceCalculator(),
  });

  final FinanceDataSource _dataSource;
  final FinanceCalculator calculator;

  @override
  Future<List<Movement>> getMovements() {
    return _dataSource.getMovements();
  }

  @override
  FinancialSummary getSummary(List<Movement> movements) {
    return calculator.summary(movements);
  }

  @override
  Future<void> createMovement(Movement movement) {
    movement.validate();
    return _dataSource.saveMovement(movement);
  }

  @override
  Future<void> updateMovement(Movement movement) {
    movement.validate();
    return _dataSource.saveMovement(movement);
  }

  @override
  Future<void> deleteMovement(String id) {
    if (id.trim().isEmpty) {
      throw const MovementValidationException(
          'El id del movimiento es invalido');
    }

    return _dataSource.deleteMovement(id);
  }
}
