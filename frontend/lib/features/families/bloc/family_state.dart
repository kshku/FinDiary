import 'package:equatable/equatable.dart';
import 'package:findiary/core/database/database.dart';

sealed class FamilyState extends Equatable {
  const FamilyState();

  @override
  List<Object?> get props => [];
}

final class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

final class FamilyLoading extends FamilyState {
  const FamilyLoading();
}

final class FamilyLoaded extends FamilyState {
  final List<Family> families;

  const FamilyLoaded({required this.families});

  @override
  List<Object?> get props => [families];
}

final class FamilyFailure extends FamilyState {
  final String message;

  const FamilyFailure(this.message);

  @override
  List<Object?> get props => [message];
}
