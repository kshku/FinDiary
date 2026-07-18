import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findiary/core/database/daos/category_dao.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryDao _categoryDao;

  CategoryBloc({required this._categoryDao})
      : super(const CategoryInitial()) {
    on<CategoryRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CategoryRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final all = await _categoryDao.listCategories();
      emit(CategoryLoaded(
        incomeCategories: all.where((c) => c.type == 'income').toList(),
        expenseCategories: all.where((c) => c.type == 'expense').toList(),
      ));
    } catch (_) {
      emit(const CategoryLoaded(incomeCategories: [], expenseCategories: []));
    }
  }
}
