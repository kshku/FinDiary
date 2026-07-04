import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $pb;

import '../../generated/findiary/v1/family_service.pbgrpc.dart';
import '../../generated/findiary/v1/common.pb.dart';
import '../client/grpc_client.dart';

class FamilyGrpcService {
  final FamilyServiceClient _stub;

  FamilyGrpcService(GrpcClient grpcClient)
      : _stub = FamilyServiceClient(grpcClient.channel);

  Future<Family> createFamily(String name) async {
    final request = CreateFamilyRequest()..name = name;
    final response = await _stub.createFamily(request);
    return response.family;
  }

  Future<Family> getFamily(String id) async {
    final request = GetFamilyRequest()..id = id;
    final response = await _stub.getFamily(request);
    return response.family;
  }

  Future<Family> updateFamily(String id, String name) async {
    final request = UpdateFamilyRequest()
      ..id = id
      ..name = name;
    final response = await _stub.updateFamily(request);
    return response.family;
  }

  Future<List<Family>> listMyFamilies() async {
    final response = await _stub.listMyFamilies($pb.Empty());
    return response.families;
  }

  Future<FamilyMember> addMember(String familyId, String userId, String role) async {
    final request = AddMemberRequest()
      ..familyId = familyId
      ..userId = userId
      ..role = role;
    final response = await _stub.addMember(request);
    return response.member;
  }

  Future<Invitation> inviteMember(String familyId, String email) async {
    final request = InviteMemberRequest()
      ..familyId = familyId
      ..email = email;
    final response = await _stub.inviteMember(request);
    return response.invitation;
  }

  Future<FamilyMember> acceptInvitation(String code) async {
    final request = AcceptInvitationRequest()..code = code;
    final response = await _stub.acceptInvitation(request);
    return response.member;
  }

  Future<List<Invitation>> listInvitations(String familyId) async {
    final request = ListInvitationsRequest()..familyId = familyId;
    final response = await _stub.listInvitations(request);
    return response.invitations;
  }

  Future<List<FamilyMember>> listMembers(String familyId) async {
    final request = ListMembersRequest()..familyId = familyId;
    final response = await _stub.listMembers(request);
    return response.members;
  }
}
