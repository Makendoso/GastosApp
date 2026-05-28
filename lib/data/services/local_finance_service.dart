import '../database/app_database.dart';
import '../models/category.dart';
import '../models/movement.dart' as finance;
import 'category_data_source.dart';
import 'finance_data_source.dart';

class LocalFinanceService implements FinanceDataSource, CategoryDataSource {
  const LocalFinanceService(this._database);

  final AppDatabase _database;

  static Future<LocalFinanceService> initialize() async {
    return LocalFinanceService(AppDatabase());
  }

  @override
  Future<List<finance.Movement>> getMovements() {
    return _database.getMovements();
  }

  @override
  Future<void> saveMovement(finance.Movement movement) {
    return _database.saveMovement(movement);
  }

  @override
  Future<void> deleteMovement(String id) {
    return _database.deleteMovement(id);
  }

  @override
  Future<List<Category>> getCategories() {
    return _database.getCategories();
  }

  @override
  Future<void> saveCategory(Category category) {
    return _database.saveCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) {
    return _database.deleteCategory(id);
  }
}
