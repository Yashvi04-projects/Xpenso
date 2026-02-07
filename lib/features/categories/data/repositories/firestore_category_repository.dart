import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class FirestoreCategoryRepository implements CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository;

  FirestoreCategoryRepository(this._authRepository);

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception('Auth required');
    return user.uid;
  }

  @override
  Future<List<Category>> getCategories() async {
    final snapshot = await _firestore.collection('categories')
        .where('userId', isEqualTo: _userId)
        .get();
    
    // If empty, seed default categories for the user
    if (snapshot.docs.isEmpty) {
      await _seedDefaultCategories();
      return getCategories();
    }

    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add({
      'userId': _userId,
      'name': category.name,
      'monthlyLimit': category.monthlyLimit,
    });
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).update({
      'name': category.name,
      'monthlyLimit': category.monthlyLimit,
    });
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final doc = await _firestore.collection('categories').doc(id).get();
    if (doc.exists) {
      return Category.fromFirestore(doc);
    }
    return null;
  }

  Future<void> _seedDefaultCategories() async {
    final defaults = [
      {'name': 'Food', 'monthlyLimit': 15000.0},
      {'name': 'Shopping', 'monthlyLimit': 5000.0},
      {'name': 'Transport', 'monthlyLimit': 3000.0},
      {'name': 'Rent', 'monthlyLimit': 40000.0},
      {'name': 'Fun', 'monthlyLimit': 5000.0},
    ];

    final batch = _firestore.batch();
    for (var item in defaults) {
      final docRef = _firestore.collection('categories').doc();
      batch.set(docRef, {
        'userId': _userId,
        'name': item['name'],
        'monthlyLimit': item['monthlyLimit'],
      });
    }
    await batch.commit();
  }
}
