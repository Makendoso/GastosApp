import '../models/category.dart';
import '../models/movement.dart';
import '../services/category_data_source.dart';
import 'category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  const LocalCategoryRepository(this._dataSource);

  final CategoryDataSource _dataSource;

  @override
  Future<List<Category>> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  Future<void> createCategory(Category category) {
    _validate(category);
    return _dataSource.saveCategory(category);
  }

  @override
  Future<void> updateCategory(Category category) {
    _validate(category);
    return _dataSource.saveCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) {
    if (id.trim().isEmpty) {
      throw const MovementValidationException(
        'El id de la categoria es invalido',
      );
    }

    return _dataSource.deleteCategory(id);
  }

  void _validate(Category category) {
    if (category.id.trim().isEmpty) {
      throw const MovementValidationException(
        'El id de la categoria es invalido',
      );
    }

    if (category.name.trim().isEmpty) {
      throw const MovementValidationException(
        'El nombre de la categoria no puede estar vacio',
      );
    }
  }
}
