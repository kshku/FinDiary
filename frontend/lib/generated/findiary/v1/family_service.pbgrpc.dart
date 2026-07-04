// This is a generated file - do not edit.
//
// Generated from findiary/v1/family_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'family_service.pb.dart' as $0;

export 'family_service.pb.dart';

@$pb.GrpcServiceName('findiary.v1.FamilyService')
class FamilyServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FamilyServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CreateFamilyResponse> createFamily(
    $0.CreateFamilyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createFamily, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetFamilyResponse> getFamily(
    $0.GetFamilyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFamily, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateFamilyResponse> updateFamily(
    $0.UpdateFamilyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateFamily, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListMyFamiliesResponse> listMyFamilies(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMyFamilies, request, options: options);
  }

  $grpc.ResponseFuture<$0.AddMemberResponse> addMember(
    $0.AddMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$addMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.RemoveMemberResponse> removeMember(
    $0.RemoveMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$removeMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.InviteMemberResponse> inviteMember(
    $0.InviteMemberRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$inviteMember, request, options: options);
  }

  $grpc.ResponseFuture<$0.AcceptInvitationResponse> acceptInvitation(
    $0.AcceptInvitationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$acceptInvitation, request, options: options);
  }

  $grpc.ResponseFuture<$0.RevokeInvitationResponse> revokeInvitation(
    $0.RevokeInvitationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeInvitation, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListInvitationsResponse> listInvitations(
    $0.ListInvitationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listInvitations, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListMembersResponse> listMembers(
    $0.ListMembersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listMembers, request, options: options);
  }

  // method descriptors

  static final _$createFamily =
      $grpc.ClientMethod<$0.CreateFamilyRequest, $0.CreateFamilyResponse>(
          '/findiary.v1.FamilyService/CreateFamily',
          ($0.CreateFamilyRequest value) => value.writeToBuffer(),
          $0.CreateFamilyResponse.fromBuffer);
  static final _$getFamily =
      $grpc.ClientMethod<$0.GetFamilyRequest, $0.GetFamilyResponse>(
          '/findiary.v1.FamilyService/GetFamily',
          ($0.GetFamilyRequest value) => value.writeToBuffer(),
          $0.GetFamilyResponse.fromBuffer);
  static final _$updateFamily =
      $grpc.ClientMethod<$0.UpdateFamilyRequest, $0.UpdateFamilyResponse>(
          '/findiary.v1.FamilyService/UpdateFamily',
          ($0.UpdateFamilyRequest value) => value.writeToBuffer(),
          $0.UpdateFamilyResponse.fromBuffer);
  static final _$listMyFamilies =
      $grpc.ClientMethod<$1.Empty, $0.ListMyFamiliesResponse>(
          '/findiary.v1.FamilyService/ListMyFamilies',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ListMyFamiliesResponse.fromBuffer);
  static final _$addMember =
      $grpc.ClientMethod<$0.AddMemberRequest, $0.AddMemberResponse>(
          '/findiary.v1.FamilyService/AddMember',
          ($0.AddMemberRequest value) => value.writeToBuffer(),
          $0.AddMemberResponse.fromBuffer);
  static final _$removeMember =
      $grpc.ClientMethod<$0.RemoveMemberRequest, $0.RemoveMemberResponse>(
          '/findiary.v1.FamilyService/RemoveMember',
          ($0.RemoveMemberRequest value) => value.writeToBuffer(),
          $0.RemoveMemberResponse.fromBuffer);
  static final _$inviteMember =
      $grpc.ClientMethod<$0.InviteMemberRequest, $0.InviteMemberResponse>(
          '/findiary.v1.FamilyService/InviteMember',
          ($0.InviteMemberRequest value) => value.writeToBuffer(),
          $0.InviteMemberResponse.fromBuffer);
  static final _$acceptInvitation = $grpc.ClientMethod<
          $0.AcceptInvitationRequest, $0.AcceptInvitationResponse>(
      '/findiary.v1.FamilyService/AcceptInvitation',
      ($0.AcceptInvitationRequest value) => value.writeToBuffer(),
      $0.AcceptInvitationResponse.fromBuffer);
  static final _$revokeInvitation = $grpc.ClientMethod<
          $0.RevokeInvitationRequest, $0.RevokeInvitationResponse>(
      '/findiary.v1.FamilyService/RevokeInvitation',
      ($0.RevokeInvitationRequest value) => value.writeToBuffer(),
      $0.RevokeInvitationResponse.fromBuffer);
  static final _$listInvitations =
      $grpc.ClientMethod<$0.ListInvitationsRequest, $0.ListInvitationsResponse>(
          '/findiary.v1.FamilyService/ListInvitations',
          ($0.ListInvitationsRequest value) => value.writeToBuffer(),
          $0.ListInvitationsResponse.fromBuffer);
  static final _$listMembers =
      $grpc.ClientMethod<$0.ListMembersRequest, $0.ListMembersResponse>(
          '/findiary.v1.FamilyService/ListMembers',
          ($0.ListMembersRequest value) => value.writeToBuffer(),
          $0.ListMembersResponse.fromBuffer);
}

@$pb.GrpcServiceName('findiary.v1.FamilyService')
abstract class FamilyServiceBase extends $grpc.Service {
  $core.String get $name => 'findiary.v1.FamilyService';

  FamilyServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.CreateFamilyRequest, $0.CreateFamilyResponse>(
            'CreateFamily',
            createFamily_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.CreateFamilyRequest.fromBuffer(value),
            ($0.CreateFamilyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetFamilyRequest, $0.GetFamilyResponse>(
        'GetFamily',
        getFamily_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetFamilyRequest.fromBuffer(value),
        ($0.GetFamilyResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UpdateFamilyRequest, $0.UpdateFamilyResponse>(
            'UpdateFamily',
            updateFamily_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UpdateFamilyRequest.fromBuffer(value),
            ($0.UpdateFamilyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListMyFamiliesResponse>(
        'ListMyFamilies',
        listMyFamilies_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListMyFamiliesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AddMemberRequest, $0.AddMemberResponse>(
        'AddMember',
        addMember_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AddMemberRequest.fromBuffer(value),
        ($0.AddMemberResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.RemoveMemberRequest, $0.RemoveMemberResponse>(
            'RemoveMember',
            removeMember_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.RemoveMemberRequest.fromBuffer(value),
            ($0.RemoveMemberResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.InviteMemberRequest, $0.InviteMemberResponse>(
            'InviteMember',
            inviteMember_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.InviteMemberRequest.fromBuffer(value),
            ($0.InviteMemberResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.AcceptInvitationRequest,
            $0.AcceptInvitationResponse>(
        'AcceptInvitation',
        acceptInvitation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.AcceptInvitationRequest.fromBuffer(value),
        ($0.AcceptInvitationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeInvitationRequest,
            $0.RevokeInvitationResponse>(
        'RevokeInvitation',
        revokeInvitation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.RevokeInvitationRequest.fromBuffer(value),
        ($0.RevokeInvitationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListInvitationsRequest,
            $0.ListInvitationsResponse>(
        'ListInvitations',
        listInvitations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListInvitationsRequest.fromBuffer(value),
        ($0.ListInvitationsResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ListMembersRequest, $0.ListMembersResponse>(
            'ListMembers',
            listMembers_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ListMembersRequest.fromBuffer(value),
            ($0.ListMembersResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateFamilyResponse> createFamily_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateFamilyRequest> $request) async {
    return createFamily($call, await $request);
  }

  $async.Future<$0.CreateFamilyResponse> createFamily(
      $grpc.ServiceCall call, $0.CreateFamilyRequest request);

  $async.Future<$0.GetFamilyResponse> getFamily_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetFamilyRequest> $request) async {
    return getFamily($call, await $request);
  }

  $async.Future<$0.GetFamilyResponse> getFamily(
      $grpc.ServiceCall call, $0.GetFamilyRequest request);

  $async.Future<$0.UpdateFamilyResponse> updateFamily_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateFamilyRequest> $request) async {
    return updateFamily($call, await $request);
  }

  $async.Future<$0.UpdateFamilyResponse> updateFamily(
      $grpc.ServiceCall call, $0.UpdateFamilyRequest request);

  $async.Future<$0.ListMyFamiliesResponse> listMyFamilies_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listMyFamilies($call, await $request);
  }

  $async.Future<$0.ListMyFamiliesResponse> listMyFamilies(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.AddMemberResponse> addMember_Pre($grpc.ServiceCall $call,
      $async.Future<$0.AddMemberRequest> $request) async {
    return addMember($call, await $request);
  }

  $async.Future<$0.AddMemberResponse> addMember(
      $grpc.ServiceCall call, $0.AddMemberRequest request);

  $async.Future<$0.RemoveMemberResponse> removeMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RemoveMemberRequest> $request) async {
    return removeMember($call, await $request);
  }

  $async.Future<$0.RemoveMemberResponse> removeMember(
      $grpc.ServiceCall call, $0.RemoveMemberRequest request);

  $async.Future<$0.InviteMemberResponse> inviteMember_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.InviteMemberRequest> $request) async {
    return inviteMember($call, await $request);
  }

  $async.Future<$0.InviteMemberResponse> inviteMember(
      $grpc.ServiceCall call, $0.InviteMemberRequest request);

  $async.Future<$0.AcceptInvitationResponse> acceptInvitation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.AcceptInvitationRequest> $request) async {
    return acceptInvitation($call, await $request);
  }

  $async.Future<$0.AcceptInvitationResponse> acceptInvitation(
      $grpc.ServiceCall call, $0.AcceptInvitationRequest request);

  $async.Future<$0.RevokeInvitationResponse> revokeInvitation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.RevokeInvitationRequest> $request) async {
    return revokeInvitation($call, await $request);
  }

  $async.Future<$0.RevokeInvitationResponse> revokeInvitation(
      $grpc.ServiceCall call, $0.RevokeInvitationRequest request);

  $async.Future<$0.ListInvitationsResponse> listInvitations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListInvitationsRequest> $request) async {
    return listInvitations($call, await $request);
  }

  $async.Future<$0.ListInvitationsResponse> listInvitations(
      $grpc.ServiceCall call, $0.ListInvitationsRequest request);

  $async.Future<$0.ListMembersResponse> listMembers_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ListMembersRequest> $request) async {
    return listMembers($call, await $request);
  }

  $async.Future<$0.ListMembersResponse> listMembers(
      $grpc.ServiceCall call, $0.ListMembersRequest request);
}
