// This is a generated file - do not edit.
//
// Generated from findiary/v1/common.proto.

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

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgJUgJpZBIUCgVlbWFpbBgCIAEoCVIFZW1haWwSIQoMZGlzcGxheV'
    '9uYW1lGAMgASgJUgtkaXNwbGF5TmFtZRI5CgpjcmVhdGVkX2F0GAQgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use transactionDescriptor instead')
const Transaction$json = {
  '1': 'Transaction',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'family_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {'1': 'created_by', '3': 3, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'amount', '3': 5, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'currency', '3': 6, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'category_id', '3': 7, '4': 1, '5': 9, '10': 'categoryId'},
    {
      '1': 'description',
      '3': 8,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'description',
      '17': true
    },
    {'1': 'date', '3': 9, '4': 1, '5': 9, '10': 'date'},
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'deleted_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '9': 2,
      '10': 'deletedAt',
      '17': true
    },
  ],
  '8': [
    {'1': '_family_id'},
    {'1': '_description'},
    {'1': '_deleted_at'},
  ],
};

/// Descriptor for `Transaction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionDescriptor = $convert.base64Decode(
    'CgtUcmFuc2FjdGlvbhIOCgJpZBgBIAEoCVICaWQSIAoJZmFtaWx5X2lkGAIgASgJSABSCGZhbW'
    'lseUlkiAEBEh0KCmNyZWF0ZWRfYnkYAyABKAlSCWNyZWF0ZWRCeRISCgR0eXBlGAQgASgJUgR0'
    'eXBlEhYKBmFtb3VudBgFIAEoAVIGYW1vdW50EhoKCGN1cnJlbmN5GAYgASgJUghjdXJyZW5jeR'
    'IfCgtjYXRlZ29yeV9pZBgHIAEoCVIKY2F0ZWdvcnlJZBIlCgtkZXNjcmlwdGlvbhgIIAEoCUgB'
    'UgtkZXNjcmlwdGlvbogBARISCgRkYXRlGAkgASgJUgRkYXRlEjkKCmNyZWF0ZWRfYXQYCiABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgL'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBI+CgpkZWxldGVkX2'
    'F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcEgCUglkZWxldGVkQXSIAQFCDAoK'
    'X2ZhbWlseV9pZEIOCgxfZGVzY3JpcHRpb25CDQoLX2RlbGV0ZWRfYXQ=');

@$core.Deprecated('Use categoryDescriptor instead')
const Category$json = {
  '1': 'Category',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'scope', '3': 2, '4': 1, '5': 9, '10': 'scope'},
    {
      '1': 'family_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {
      '1': 'created_by',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'createdBy',
      '17': true
    },
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'type', '3': 6, '4': 1, '5': 9, '10': 'type'},
    {'1': 'icon', '3': 7, '4': 1, '5': 9, '9': 2, '10': 'icon', '17': true},
    {'1': 'color', '3': 8, '4': 1, '5': 9, '9': 3, '10': 'color', '17': true},
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
  '8': [
    {'1': '_family_id'},
    {'1': '_created_by'},
    {'1': '_icon'},
    {'1': '_color'},
  ],
};

/// Descriptor for `Category`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List categoryDescriptor = $convert.base64Decode(
    'CghDYXRlZ29yeRIOCgJpZBgBIAEoCVICaWQSFAoFc2NvcGUYAiABKAlSBXNjb3BlEiAKCWZhbW'
    'lseV9pZBgDIAEoCUgAUghmYW1pbHlJZIgBARIiCgpjcmVhdGVkX2J5GAQgASgJSAFSCWNyZWF0'
    'ZWRCeYgBARISCgRuYW1lGAUgASgJUgRuYW1lEhIKBHR5cGUYBiABKAlSBHR5cGUSFwoEaWNvbh'
    'gHIAEoCUgCUgRpY29uiAEBEhkKBWNvbG9yGAggASgJSANSBWNvbG9yiAEBEjkKCmNyZWF0ZWRf'
    'YXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYX'
    'RlZF9hdBgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdEIMCgpf'
    'ZmFtaWx5X2lkQg0KC19jcmVhdGVkX2J5QgcKBV9pY29uQggKBl9jb2xvcg==');

@$core.Deprecated('Use familyDescriptor instead')
const Family$json = {
  '1': 'Family',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'owner_id', '3': 3, '4': 1, '5': 9, '10': 'ownerId'},
    {
      '1': 'created_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `Family`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List familyDescriptor = $convert.base64Decode(
    'CgZGYW1pbHkSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSGQoIb3duZXJfaW'
    'QYAyABKAlSB293bmVySWQSOQoKY3JlYXRlZF9hdBgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAUgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use familyMemberDescriptor instead')
const FamilyMember$json = {
  '1': 'FamilyMember',
  '2': [
    {'1': 'family_id', '3': 1, '4': 1, '5': 9, '10': 'familyId'},
    {'1': 'user_id', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'role', '3': 3, '4': 1, '5': 9, '10': 'role'},
    {
      '1': 'joined_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'joinedAt'
    },
  ],
};

/// Descriptor for `FamilyMember`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List familyMemberDescriptor = $convert.base64Decode(
    'CgxGYW1pbHlNZW1iZXISGwoJZmFtaWx5X2lkGAEgASgJUghmYW1pbHlJZBIXCgd1c2VyX2lkGA'
    'IgASgJUgZ1c2VySWQSEgoEcm9sZRgDIAEoCVIEcm9sZRI3Cglqb2luZWRfYXQYBCABKAsyGi5n'
    'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUghqb2luZWRBdA==');

@$core.Deprecated('Use invitationDescriptor instead')
const Invitation$json = {
  '1': 'Invitation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'family_id', '3': 2, '4': 1, '5': 9, '10': 'familyId'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'created_by', '3': 5, '4': 1, '5': 9, '10': 'createdBy'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'expires_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
  ],
};

/// Descriptor for `Invitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationDescriptor = $convert.base64Decode(
    'CgpJbnZpdGF0aW9uEg4KAmlkGAEgASgJUgJpZBIbCglmYW1pbHlfaWQYAiABKAlSCGZhbWlseU'
    'lkEhQKBWVtYWlsGAMgASgJUgVlbWFpbBIWCgZzdGF0dXMYBCABKAlSBnN0YXR1cxIdCgpjcmVh'
    'dGVkX2J5GAUgASgJUgljcmVhdGVkQnkSOQoKY3JlYXRlZF9hdBgGIAEoCzIaLmdvb2dsZS5wcm'
    '90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5CgpleHBpcmVzX2F0GAcgASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFIJZXhwaXJlc0F0');

@$core.Deprecated('Use changeEntryDescriptor instead')
const ChangeEntry$json = {
  '1': 'ChangeEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {
      '1': 'family_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {'1': 'changed_by', '3': 3, '4': 1, '5': 9, '10': 'changedBy'},
    {'1': 'entity_type', '3': 4, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'entity_id', '3': 5, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'action', '3': 6, '4': 1, '5': 9, '10': 'action'},
    {'1': 'snapshot', '3': 7, '4': 1, '5': 12, '10': 'snapshot'},
    {'1': 'changed_fields', '3': 8, '4': 3, '5': 9, '10': 'changedFields'},
    {
      '1': 'server_timestamp',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'serverTimestamp'
    },
    {
      '1': 'client_timestamp',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'clientTimestamp'
    },
  ],
  '8': [
    {'1': '_family_id'},
  ],
};

/// Descriptor for `ChangeEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changeEntryDescriptor = $convert.base64Decode(
    'CgtDaGFuZ2VFbnRyeRIOCgJpZBgBIAEoA1ICaWQSIAoJZmFtaWx5X2lkGAIgASgJSABSCGZhbW'
    'lseUlkiAEBEh0KCmNoYW5nZWRfYnkYAyABKAlSCWNoYW5nZWRCeRIfCgtlbnRpdHlfdHlwZRgE'
    'IAEoCVIKZW50aXR5VHlwZRIbCgllbnRpdHlfaWQYBSABKAlSCGVudGl0eUlkEhYKBmFjdGlvbh'
    'gGIAEoCVIGYWN0aW9uEhoKCHNuYXBzaG90GAcgASgMUghzbmFwc2hvdBIlCg5jaGFuZ2VkX2Zp'
    'ZWxkcxgIIAMoCVINY2hhbmdlZEZpZWxkcxJFChBzZXJ2ZXJfdGltZXN0YW1wGAkgASgLMhouZ2'
    '9vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIPc2VydmVyVGltZXN0YW1wEkUKEGNsaWVudF90aW1l'
    'c3RhbXAYCiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg9jbGllbnRUaW1lc3RhbX'
    'BCDAoKX2ZhbWlseV9pZA==');
