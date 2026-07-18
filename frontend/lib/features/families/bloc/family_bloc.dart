import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart';
import 'package:findiary/core/database/database.dart';
import 'package:findiary/core/database/daos/family_dao.dart';
import 'package:findiary/core/grpc/family_service.dart';
import 'family_event.dart';
import 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyDao _familyDao;
  final FamilyGrpcService _familyGrpcService;

  FamilyBloc({
    required this._familyDao,
    required this._familyGrpcService,
  }) : super(const FamilyInitial()) {
    on<FamiliesRequested>(_onRequested);
    on<FamilyCreated>(_onCreated);
  }

  Future<void> _onRequested(
    FamiliesRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final families = await _familyDao.listFamilies();
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onCreated(
    FamilyCreated event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final created = await _familyGrpcService.createFamily(event.name);
      final now = DateTime.now().toIso8601String();
      await _familyDao.upsertFamily(FamiliesCompanion(
        id: Value(created.id),
        name: Value(created.name),
        ownerId: Value(created.ownerId),
        createdAt: Value(created.hasCreatedAt()
            ? created.createdAt.toDateTime().toIso8601String()
            : now),
        updatedAt: Value(created.hasUpdatedAt()
            ? created.updatedAt.toDateTime().toIso8601String()
            : now),
      ));
      final families = await _familyDao.listFamilies();
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }
}
