import 'package:equatable/equatable.dart';

sealed class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

final class FamiliesRequested extends FamilyEvent {
  const FamiliesRequested();
}

final class FamilyCreated extends FamilyEvent {
  final String name;

  const FamilyCreated(this.name);

  @override
  List<Object?> get props => [name];
}
