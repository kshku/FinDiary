import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Scope extends Equatable {
  final String scopeId;
  final String scopeType;
  final String label;

  const Scope({
    this.scopeId = 'personal',
    this.scopeType = 'personal',
    this.label = 'Personal',
  });

  bool get isPersonal => scopeType == 'personal';

  @override
  List<Object?> get props => [scopeId, scopeType, label];
}

class ScopeCubit extends Cubit<Scope> {
  ScopeCubit() : super(const Scope());

  void switchToPersonal() => emit(const Scope());

  void switchToFamily(String familyId, String familyName) =>
      emit(Scope(scopeId: familyId, scopeType: 'family', label: familyName));
}
