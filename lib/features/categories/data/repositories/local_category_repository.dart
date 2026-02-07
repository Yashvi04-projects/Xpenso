import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class LocalCategoryRepository implements CategoryRepository {
  // Mock Data matching the Stitch UI Image
  final List<Category> _categories = [
    Category(id: '1', userId: 'local_user', name: 'Food & Dining', monthlyLimit: 15000),
    Category(id: '3', userId: 'local_user', name: 'Shopping', monthlyLimit: 9000), // Using '3' to match Expense helper
    Category(id: '2', userId: 'local_user', name: 'Transportation', monthlyLimit: 7500),
    Category(id: '4', userId: 'local_user', name: 'Rent & Utilities', monthlyLimit: 36000),
  ];

  static final LocalCategoryRepository _instance = LocalCategoryRepository._internal();
  factory LocalCategoryRepository() => _instance;
  LocalCategoryRepository._internal();

  @override
  Future<void> addCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _categories.add(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories.removeWhere((element) => element.id == id);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _categories.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_categories);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _categories.indexWhere((element) => element.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }
}
