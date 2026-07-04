import 'package:drift/drift.dart';
import '../database.dart';

class CategoryDao extends DatabaseAccessor<AppDatabase> {
  CategoryDao(super.db);

  Future<void> upsertCategory(CategoriesCompanion entry) {
    return into(db.categories).insertOnConflictUpdate(entry);
  }

  Future<Category?> getCategory(String id) {
    return (select(db.categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<List<Category>> listCategories({
    String? scope,
    String? familyId,
    String? type,
  }) {
    var query = select(db.categories)..orderBy([(c) => OrderingTerm.asc(c.name)]);

    if (scope != null && scope.isNotEmpty) {
      query.where((c) => c.scope.equals(scope));
    }
    if (familyId != null && familyId.isNotEmpty) {
      query.where((c) => c.familyId.equals(familyId) | c.scope.equals('system'));
    } else {
      query.where((c) => c.familyId.isNull());
    }
    if (type != null && type.isNotEmpty) {
      query.where((c) => c.type.equals(type));
    }

    return query.get();
  }

  Future<void> deleteCategory(String id) {
    return (delete(db.categories)..where((c) => c.id.equals(id))).go();
  }
}
