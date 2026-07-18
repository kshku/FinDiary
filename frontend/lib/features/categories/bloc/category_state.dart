import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  final List<Category> incomeCategories;
  final List<Category> expenseCategories;

  const CategoryLoaded({
    required this.incomeCategories,
    required this.expenseCategories,
  });

  @override
  List<Object?> get props => [incomeCategories, expenseCategories];
}
