import '../models/category.dart';

abstract interface class CategoryDataSource {
  Future<List<Category>> getCategories();

  Future<void> saveCategory(Category category);

  Future<void> deleteCategory(String id);
}
