import '../models/category.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> getCategories();

  Future<void> createCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}
