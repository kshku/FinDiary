// This is a generated file - do not edit.
//
// Generated from findiary/v1/sync_service.proto.

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

@$core.Deprecated('Use syncRequestDescriptor instead')
const SyncRequest$json = {
  '1': 'SyncRequest',
  '2': [
    {'1': 'scope_id', '3': 1, '4': 1, '5': 9, '10': 'scopeId'},
    {'1': 'scope_type', '3': 2, '4': 1, '5': 9, '10': 'scopeType'},
    {'1': 'last_checkpoint', '3': 3, '4': 1, '5': 3, '10': 'lastCheckpoint'},
    {
      '1': 'local_changes',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.SyncChangeEntry',
      '10': 'localChanges'
    },
  ],
};

/// Descriptor for `SyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncRequestDescriptor = $convert.base64Decode(
    'CgtTeW5jUmVxdWVzdBIZCghzY29wZV9pZBgBIAEoCVIHc2NvcGVJZBIdCgpzY29wZV90eXBlGA'
    'IgASgJUglzY29wZVR5cGUSJwoPbGFzdF9jaGVja3BvaW50GAMgASgDUg5sYXN0Q2hlY2twb2lu'
    'dBJBCg1sb2NhbF9jaGFuZ2VzGAQgAygLMhwuZmluZGlhcnkudjEuU3luY0NoYW5nZUVudHJ5Ug'
    'xsb2NhbENoYW5nZXM=');

@$core.Deprecated('Use syncResponseDescriptor instead')
const SyncResponse$json = {
  '1': 'SyncResponse',
  '2': [
    {'1': 'new_checkpoint', '3': 1, '4': 1, '5': 3, '10': 'newCheckpoint'},
    {
      '1': 'remote_changes',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.SyncChangeEntry',
      '10': 'remoteChanges'
    },
    {
      '1': 'conflicts',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.ConflictInfo',
      '10': 'conflicts'
    },
  ],
};

/// Descriptor for `SyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncResponseDescriptor = $convert.base64Decode(
    'CgxTeW5jUmVzcG9uc2USJQoObmV3X2NoZWNrcG9pbnQYASABKANSDW5ld0NoZWNrcG9pbnQSQw'
    'oOcmVtb3RlX2NoYW5nZXMYAiADKAsyHC5maW5kaWFyeS52MS5TeW5jQ2hhbmdlRW50cnlSDXJl'
    'bW90ZUNoYW5nZXMSNwoJY29uZmxpY3RzGAMgAygLMhkuZmluZGlhcnkudjEuQ29uZmxpY3RJbm'
    'ZvUgljb25mbGljdHM=');

@$core.Deprecated('Use syncChangeEntryDescriptor instead')
const SyncChangeEntry$json = {
  '1': 'SyncChangeEntry',
  '2': [
    {'1': 'entity_type', '3': 1, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'entity_id', '3': 2, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'action', '3': 3, '4': 1, '5': 9, '10': 'action'},
    {'1': 'snapshot', '3': 4, '4': 1, '5': 12, '10': 'snapshot'},
    {
      '1': 'client_timestamp',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'clientTimestamp'
    },
    {'1': 'changed_fields', '3': 6, '4': 3, '5': 9, '10': 'changedFields'},
  ],
};

/// Descriptor for `SyncChangeEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncChangeEntryDescriptor = $convert.base64Decode(
    'Cg9TeW5jQ2hhbmdlRW50cnkSHwoLZW50aXR5X3R5cGUYASABKAlSCmVudGl0eVR5cGUSGwoJZW'
    '50aXR5X2lkGAIgASgJUghlbnRpdHlJZBIWCgZhY3Rpb24YAyABKAlSBmFjdGlvbhIaCghzbmFw'
    'c2hvdBgEIAEoDFIIc25hcHNob3QSRQoQY2xpZW50X3RpbWVzdGFtcBgFIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSD2NsaWVudFRpbWVzdGFtcBIlCg5jaGFuZ2VkX2ZpZWxkcxgG'
    'IAMoCVINY2hhbmdlZEZpZWxkcw==');

@$core.Deprecated('Use conflictInfoDescriptor instead')
const ConflictInfo$json = {
  '1': 'ConflictInfo',
  '2': [
    {'1': 'entity_type', '3': 1, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'entity_id', '3': 2, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'field', '3': 3, '4': 1, '5': 9, '10': 'field'},
    {'1': 'local_value', '3': 4, '4': 1, '5': 9, '10': 'localValue'},
    {'1': 'server_value', '3': 5, '4': 1, '5': 9, '10': 'serverValue'},
  ],
};

/// Descriptor for `ConflictInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conflictInfoDescriptor = $convert.base64Decode(
    'CgxDb25mbGljdEluZm8SHwoLZW50aXR5X3R5cGUYASABKAlSCmVudGl0eVR5cGUSGwoJZW50aX'
    'R5X2lkGAIgASgJUghlbnRpdHlJZBIUCgVmaWVsZBgDIAEoCVIFZmllbGQSHwoLbG9jYWxfdmFs'
    'dWUYBCABKAlSCmxvY2FsVmFsdWUSIQoMc2VydmVyX3ZhbHVlGAUgASgJUgtzZXJ2ZXJWYWx1ZQ'
    '==');
