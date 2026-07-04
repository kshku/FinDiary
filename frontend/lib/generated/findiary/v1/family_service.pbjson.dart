// This is a generated file - do not edit.
//
// Generated from findiary/v1/family_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use createFamilyRequestDescriptor instead')
const CreateFamilyRequest$json = {
  '1': 'CreateFamilyRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `CreateFamilyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFamilyRequestDescriptor = $convert
    .base64Decode('ChNDcmVhdGVGYW1pbHlSZXF1ZXN0EhIKBG5hbWUYASABKAlSBG5hbWU=');

@$core.Deprecated('Use createFamilyResponseDescriptor instead')
const CreateFamilyResponse$json = {
  '1': 'CreateFamilyResponse',
  '2': [
    {
      '1': 'family',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Family',
      '10': 'family'
    },
  ],
};

/// Descriptor for `CreateFamilyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFamilyResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVGYW1pbHlSZXNwb25zZRIrCgZmYW1pbHkYASABKAsyEy5maW5kaWFyeS52MS5GYW'
    '1pbHlSBmZhbWlseQ==');

@$core.Deprecated('Use getFamilyRequestDescriptor instead')
const GetFamilyRequest$json = {
  '1': 'GetFamilyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetFamilyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFamilyRequestDescriptor =
    $convert.base64Decode('ChBHZXRGYW1pbHlSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getFamilyResponseDescriptor instead')
const GetFamilyResponse$json = {
  '1': 'GetFamilyResponse',
  '2': [
    {
      '1': 'family',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Family',
      '10': 'family'
    },
  ],
};

/// Descriptor for `GetFamilyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFamilyResponseDescriptor = $convert.base64Decode(
    'ChFHZXRGYW1pbHlSZXNwb25zZRIrCgZmYW1pbHkYASABKAsyEy5maW5kaWFyeS52MS5GYW1pbH'
    'lSBmZhbWlseQ==');

@$core.Deprecated('Use updateFamilyRequestDescriptor instead')
const UpdateFamilyRequest$json = {
  '1': 'UpdateFamilyRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `UpdateFamilyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFamilyRequestDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVGYW1pbHlSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBISCgRuYW1lGAIgASgJUgRuYW'
    '1l');

@$core.Deprecated('Use updateFamilyResponseDescriptor instead')
const UpdateFamilyResponse$json = {
  '1': 'UpdateFamilyResponse',
  '2': [
    {
      '1': 'family',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Family',
      '10': 'family'
    },
  ],
};

/// Descriptor for `UpdateFamilyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFamilyResponseDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVGYW1pbHlSZXNwb25zZRIrCgZmYW1pbHkYASABKAsyEy5maW5kaWFyeS52MS5GYW'
    '1pbHlSBmZhbWlseQ==');

@$core.Deprecated('Use listMyFamiliesResponseDescriptor instead')
const ListMyFamiliesResponse$json = {
  '1': 'ListMyFamiliesResponse',
  '2': [
    {
      '1': 'families',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.Family',
      '10': 'families'
    },
  ],
};

/// Descriptor for `ListMyFamiliesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMyFamiliesResponseDescriptor =
    $convert.base64Decode(
        'ChZMaXN0TXlGYW1pbGllc1Jlc3BvbnNlEi8KCGZhbWlsaWVzGAEgAygLMhMuZmluZGlhcnkudj'
        'EuRmFtaWx5UghmYW1pbGllcw==');

@$core.Deprecated('Use addMemberRequestDescriptor instead')
const AddMemberRequest$json = {
  '1': 'AddMemberRequest',
  '2': [
    {'1': 'family_id', '3': 1, '4': 1, '5': 9, '10': 'familyId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'role', '3': 3, '4': 1, '5': 9, '10': 'role'},
  ],
};

/// Descriptor for `AddMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMemberRequestDescriptor = $convert.base64Decode(
    'ChBBZGRNZW1iZXJSZXF1ZXN0EhsKCWZhbWlseV9pZBgBIAEoCVIIZmFtaWx5SWQSFwoHdXNlcl'
    '9pZBgCIAEoCVIGdXNlcklkEhIKBHJvbGUYAyABKAlSBHJvbGU=');

@$core.Deprecated('Use addMemberResponseDescriptor instead')
const AddMemberResponse$json = {
  '1': 'AddMemberResponse',
  '2': [
    {
      '1': 'member',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.FamilyMember',
      '10': 'member'
    },
  ],
};

/// Descriptor for `AddMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addMemberResponseDescriptor = $convert.base64Decode(
    'ChFBZGRNZW1iZXJSZXNwb25zZRIxCgZtZW1iZXIYASABKAsyGS5maW5kaWFyeS52MS5GYW1pbH'
    'lNZW1iZXJSBm1lbWJlcg==');

@$core.Deprecated('Use removeMemberRequestDescriptor instead')
const RemoveMemberRequest$json = {
  '1': 'RemoveMemberRequest',
  '2': [
    {'1': 'family_id', '3': 1, '4': 1, '5': 9, '10': 'familyId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `RemoveMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMemberRequestDescriptor = $convert.base64Decode(
    'ChNSZW1vdmVNZW1iZXJSZXF1ZXN0EhsKCWZhbWlseV9pZBgBIAEoCVIIZmFtaWx5SWQSFwoHdX'
    'Nlcl9pZBgCIAEoCVIGdXNlcklk');

@$core.Deprecated('Use removeMemberResponseDescriptor instead')
const RemoveMemberResponse$json = {
  '1': 'RemoveMemberResponse',
};

/// Descriptor for `RemoveMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List removeMemberResponseDescriptor =
    $convert.base64Decode('ChRSZW1vdmVNZW1iZXJSZXNwb25zZQ==');

@$core.Deprecated('Use inviteMemberRequestDescriptor instead')
const InviteMemberRequest$json = {
  '1': 'InviteMemberRequest',
  '2': [
    {'1': 'family_id', '3': 1, '4': 1, '5': 9, '10': 'familyId'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
  ],
};

/// Descriptor for `InviteMemberRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteMemberRequestDescriptor = $convert.base64Decode(
    'ChNJbnZpdGVNZW1iZXJSZXF1ZXN0EhsKCWZhbWlseV9pZBgBIAEoCVIIZmFtaWx5SWQSFAoFZW'
    '1haWwYAiABKAlSBWVtYWls');

@$core.Deprecated('Use inviteMemberResponseDescriptor instead')
const InviteMemberResponse$json = {
  '1': 'InviteMemberResponse',
  '2': [
    {
      '1': 'invitation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Invitation',
      '10': 'invitation'
    },
  ],
};

/// Descriptor for `InviteMemberResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inviteMemberResponseDescriptor = $convert.base64Decode(
    'ChRJbnZpdGVNZW1iZXJSZXNwb25zZRI3CgppbnZpdGF0aW9uGAEgASgLMhcuZmluZGlhcnkudj'
    'EuSW52aXRhdGlvblIKaW52aXRhdGlvbg==');

@$core.Deprecated('Use acceptInvitationRequestDescriptor instead')
const AcceptInvitationRequest$json = {
  '1': 'AcceptInvitationRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `AcceptInvitationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptInvitationRequestDescriptor =
    $convert.base64Decode(
        'ChdBY2NlcHRJbnZpdGF0aW9uUmVxdWVzdBISCgRjb2RlGAEgASgJUgRjb2Rl');

@$core.Deprecated('Use acceptInvitationResponseDescriptor instead')
const AcceptInvitationResponse$json = {
  '1': 'AcceptInvitationResponse',
  '2': [
    {
      '1': 'member',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.FamilyMember',
      '10': 'member'
    },
  ],
};

/// Descriptor for `AcceptInvitationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acceptInvitationResponseDescriptor =
    $convert.base64Decode(
        'ChhBY2NlcHRJbnZpdGF0aW9uUmVzcG9uc2USMQoGbWVtYmVyGAEgASgLMhkuZmluZGlhcnkudj'
        'EuRmFtaWx5TWVtYmVyUgZtZW1iZXI=');

@$core.Deprecated('Use revokeInvitationRequestDescriptor instead')
const RevokeInvitationRequest$json = {
  '1': 'RevokeInvitationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RevokeInvitationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeInvitationRequestDescriptor = $convert
    .base64Decode('ChdSZXZva2VJbnZpdGF0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use revokeInvitationResponseDescriptor instead')
const RevokeInvitationResponse$json = {
  '1': 'RevokeInvitationResponse',
  '2': [
    {
      '1': 'invitation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Invitation',
      '10': 'invitation'
    },
  ],
};

/// Descriptor for `RevokeInvitationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeInvitationResponseDescriptor =
    $convert.base64Decode(
        'ChhSZXZva2VJbnZpdGF0aW9uUmVzcG9uc2USNwoKaW52aXRhdGlvbhgBIAEoCzIXLmZpbmRpYX'
        'J5LnYxLkludml0YXRpb25SCmludml0YXRpb24=');

@$core.Deprecated('Use listInvitationsRequestDescriptor instead')
const ListInvitationsRequest$json = {
  '1': 'ListInvitationsRequest',
  '2': [
    {'1': 'family_id', '3': 1, '4': 1, '5': 9, '10': 'familyId'},
  ],
};

/// Descriptor for `ListInvitationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInvitationsRequestDescriptor =
    $convert.base64Decode(
        'ChZMaXN0SW52aXRhdGlvbnNSZXF1ZXN0EhsKCWZhbWlseV9pZBgBIAEoCVIIZmFtaWx5SWQ=');

@$core.Deprecated('Use listInvitationsResponseDescriptor instead')
const ListInvitationsResponse$json = {
  '1': 'ListInvitationsResponse',
  '2': [
    {
      '1': 'invitations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.Invitation',
      '10': 'invitations'
    },
  ],
};

/// Descriptor for `ListInvitationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInvitationsResponseDescriptor =
    $convert.base64Decode(
        'ChdMaXN0SW52aXRhdGlvbnNSZXNwb25zZRI5CgtpbnZpdGF0aW9ucxgBIAMoCzIXLmZpbmRpYX'
        'J5LnYxLkludml0YXRpb25SC2ludml0YXRpb25z');

@$core.Deprecated('Use listMembersRequestDescriptor instead')
const ListMembersRequest$json = {
  '1': 'ListMembersRequest',
  '2': [
    {'1': 'family_id', '3': 1, '4': 1, '5': 9, '10': 'familyId'},
  ],
};

/// Descriptor for `ListMembersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMembersRequestDescriptor =
    $convert.base64Decode(
        'ChJMaXN0TWVtYmVyc1JlcXVlc3QSGwoJZmFtaWx5X2lkGAEgASgJUghmYW1pbHlJZA==');

@$core.Deprecated('Use listMembersResponseDescriptor instead')
const ListMembersResponse$json = {
  '1': 'ListMembersResponse',
  '2': [
    {
      '1': 'members',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.FamilyMember',
      '10': 'members'
    },
  ],
};

/// Descriptor for `ListMembersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMembersResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0TWVtYmVyc1Jlc3BvbnNlEjMKB21lbWJlcnMYASADKAsyGS5maW5kaWFyeS52MS5GYW'
    '1pbHlNZW1iZXJSB21lbWJlcnM=');
