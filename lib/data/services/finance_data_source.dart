import '../models/movement.dart';

abstract interface class FinanceDataSource {
  Future<List<Movement>> getMovements();

  Future<void> saveMovement(Movement movement);

  Future<void> deleteMovement(String id);
}
