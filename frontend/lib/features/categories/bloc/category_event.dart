import 'package:equatable/equatable.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

final class CategoryRequested extends CategoryEvent {
  const CategoryRequested();
}
