import 'package:equatable/equatable.dart';

sealed class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

final class FamilyListRequested extends FamilyEvent {
  const FamilyListRequested();
}

final class FamilyCreated extends FamilyEvent {
  final String name;
  const FamilyCreated(this.name);
  @override
  List<Object?> get props => [name];
}

final class FamilyDetailRequested extends FamilyEvent {
  final String familyId;
  const FamilyDetailRequested(this.familyId);
  @override
  List<Object?> get props => [familyId];
}

final class InvitationsRequested extends FamilyEvent {
  const InvitationsRequested();
}

final class InvitationAccepted extends FamilyEvent {
  final String code;
  const InvitationAccepted(this.code);
  @override
  List<Object?> get props => [code];
}

final class MemberRemoved extends FamilyEvent {
  final String familyId;
  final String userId;
  const MemberRemoved(this.familyId, this.userId);
  @override
  List<Object?> get props => [familyId, userId];
}

final class FamilyDeleted extends FamilyEvent {
  final String familyId;
  const FamilyDeleted(this.familyId);
  @override
  List<Object?> get props => [familyId];
}

final class FamilyLeft extends FamilyEvent {
  final String familyId;
  const FamilyLeft(this.familyId);
  @override
  List<Object?> get props => [familyId];
}
