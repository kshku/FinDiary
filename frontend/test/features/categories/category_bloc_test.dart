import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:findiary/core/database/daos/category_dao.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/features/categories/bloc/category_bloc.dart';
import 'package:findiary/features/categories/bloc/category_event.dart';
import 'package:findiary/features/categories/bloc/category_state.dart';

class MockCategoryDao extends Mock implements CategoryDao {}

void main() {
  late MockCategoryDao mockCategoryDao;

  setUp(() {
    mockCategoryDao = MockCategoryDao();
  });

  final incomeCategory = Category(
    id: 'cat-1',
    scope: 'system',
    name: 'Salary',
    type: 'income',
    icon: 'salary',
    color: '#4CAF50',
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
  );

  final expenseCategory = Category(
    id: 'cat-2',
    scope: 'system',
    name: 'Food',
    type: 'expense',
    icon: 'food',
    color: '#FF5722',
    createdAt: '2026-01-01T00:00:00Z',
    updatedAt: '2026-01-01T00:00:00Z',
  );

  group('CategoryBloc', () {
    blocTest<CategoryBloc, CategoryState>(
      'loads and splits categories by type',
      setUp: () {
        when(() => mockCategoryDao.listCategories())
            .thenAnswer((_) async => [incomeCategory, expenseCategory]);
      },
      build: () => CategoryBloc(_categoryDao: mockCategoryDao),
      act: (bloc) => bloc.add(const CategoryRequested()),
      expect: () => [
        const CategoryLoading(),
        CategoryLoaded(
          incomeCategories: [incomeCategory],
          expenseCategories: [expenseCategory],
        ),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'handles dao error gracefully',
      setUp: () {
        when(() => mockCategoryDao.listCategories())
            .thenThrow(Exception('db error'));
      },
      build: () => CategoryBloc(_categoryDao: mockCategoryDao),
      act: (bloc) => bloc.add(const CategoryRequested()),
      expect: () => [
        const CategoryLoading(),
        const CategoryLoaded(incomeCategories: [], expenseCategories: []),
      ],
    );
  });
}
