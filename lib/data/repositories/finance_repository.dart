import '../models/financial_summary.dart';
import '../models/movement.dart';

abstract interface class FinanceRepository {
  Future<List<Movement>> getMovements();

  FinancialSummary getSummary(List<Movement> movements);

  Future<void> createMovement(Movement movement);

  Future<void> updateMovement(Movement movement);

  Future<void> deleteMovement(String id);
}
