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
    on<FamilyListRequested>(_onListRequested);
    on<FamilyCreated>(_onCreated);
    on<FamilyDetailRequested>(_onDetailRequested);
    on<InvitationsRequested>(_onInvitationsRequested);
    on<InvitationAccepted>(_onInvitationAccepted);
    on<MemberRemoved>(_onMemberRemoved);
    on<FamilyDeleted>(_onDeleted);
    on<FamilyLeft>(_onLeft);
  }

  Future<void> _onListRequested(
    FamilyListRequested event,
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

  Future<void> _onDetailRequested(
    FamilyDetailRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final family = await _familyDao.getFamily(event.familyId);
      final members = await _familyDao.listMembers(event.familyId);
      if (family == null) {
        emit(const FamilyFailure('Family not found'));
      } else {
        emit(FamilyDetailLoaded(family: family, members: members));
      }
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onInvitationsRequested(
    InvitationsRequested event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final families = await _familyDao.listFamilies();
      try {
        for (final f in families) {
          final remote = await _familyGrpcService.listInvitations(f.id);
          for (final inv in remote) {
            await _familyDao.upsertInvitation(InvitationsCompanion(
              id: Value(inv.id),
              familyId: Value(inv.familyId),
              familyName: Value(f.name),
              email: Value(inv.email),
              code: const Value(''),
              status: Value(inv.status),
              createdBy: Value(inv.createdBy),
              createdAt: Value(inv.hasCreatedAt()
                  ? inv.createdAt.toDateTime().toIso8601String()
                  : ''),
              expiresAt: Value(inv.hasExpiresAt()
                  ? inv.expiresAt.toDateTime().toIso8601String()
                  : ''),
            ));
          }
        }
      } catch (_) {
        // Offline — use cached
      }
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onInvitationAccepted(
    InvitationAccepted event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final member = await _familyGrpcService.acceptInvitation(event.code);
      final now = DateTime.now().toIso8601String();
      await _familyDao.addMember(FamilyMembersCompanion(
        familyId: Value(member.familyId),
        userId: Value(member.userId),
        role: Value(member.role),
        joinedAt: Value(member.hasJoinedAt()
            ? member.joinedAt.toDateTime().toIso8601String()
            : now),
        invitedBy: const Value(''),
      ));
      await _familyDao.removeInvitation(event.code);
      final families = await _familyDao.listFamilies();
      emit(FamilyLoaded(families: families));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onMemberRemoved(
    MemberRemoved event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      await _familyGrpcService.removeMember(event.familyId, event.userId);
      await _familyDao.removeMember(event.familyId, event.userId);
      add(FamilyDetailRequested(event.familyId));
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onDeleted(
    FamilyDeleted event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      await _familyDao.removeFamily(event.familyId);
      add(const FamilyListRequested());
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }

  Future<void> _onLeft(
    FamilyLeft event,
    Emitter<FamilyState> emit,
  ) async {
    try {
      await _familyDao.removeMember(event.familyId, 'current-user-id');
      await _familyDao.removeFamily(event.familyId);
      add(const FamilyListRequested());
    } catch (e) {
      emit(FamilyFailure(e.toString()));
    }
  }
}
