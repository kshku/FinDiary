// This is a generated file - do not edit.
//
// Generated from findiary/v1/transaction_service.proto.

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

@$core.Deprecated('Use createTransactionRequestDescriptor instead')
const CreateTransactionRequest$json = {
  '1': 'CreateTransactionRequest',
  '2': [
    {
      '1': 'family_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'amount', '3': 3, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'category_id', '3': 5, '4': 1, '5': 9, '10': 'categoryId'},
    {
      '1': 'description',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'description',
      '17': true
    },
    {'1': 'date', '3': 7, '4': 1, '5': 9, '10': 'date'},
  ],
  '8': [
    {'1': '_family_id'},
    {'1': '_description'},
  ],
};

/// Descriptor for `CreateTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTransactionRequestDescriptor = $convert.base64Decode(
    'ChhDcmVhdGVUcmFuc2FjdGlvblJlcXVlc3QSIAoJZmFtaWx5X2lkGAEgASgJSABSCGZhbWlseU'
    'lkiAEBEhIKBHR5cGUYAiABKAlSBHR5cGUSFgoGYW1vdW50GAMgASgBUgZhbW91bnQSGgoIY3Vy'
    'cmVuY3kYBCABKAlSCGN1cnJlbmN5Eh8KC2NhdGVnb3J5X2lkGAUgASgJUgpjYXRlZ29yeUlkEi'
    'UKC2Rlc2NyaXB0aW9uGAYgASgJSAFSC2Rlc2NyaXB0aW9uiAEBEhIKBGRhdGUYByABKAlSBGRh'
    'dGVCDAoKX2ZhbWlseV9pZEIOCgxfZGVzY3JpcHRpb24=');

@$core.Deprecated('Use createTransactionResponseDescriptor instead')
const CreateTransactionResponse$json = {
  '1': 'CreateTransactionResponse',
  '2': [
    {
      '1': 'transaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Transaction',
      '10': 'transaction'
    },
  ],
};

/// Descriptor for `CreateTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createTransactionResponseDescriptor =
    $convert.base64Decode(
        'ChlDcmVhdGVUcmFuc2FjdGlvblJlc3BvbnNlEjoKC3RyYW5zYWN0aW9uGAEgASgLMhguZmluZG'
        'lhcnkudjEuVHJhbnNhY3Rpb25SC3RyYW5zYWN0aW9u');

@$core.Deprecated('Use getTransactionRequestDescriptor instead')
const GetTransactionRequest$json = {
  '1': 'GetTransactionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionRequestDescriptor = $convert
    .base64Decode('ChVHZXRUcmFuc2FjdGlvblJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getTransactionResponseDescriptor instead')
const GetTransactionResponse$json = {
  '1': 'GetTransactionResponse',
  '2': [
    {
      '1': 'transaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Transaction',
      '10': 'transaction'
    },
  ],
};

/// Descriptor for `GetTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTransactionResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRUcmFuc2FjdGlvblJlc3BvbnNlEjoKC3RyYW5zYWN0aW9uGAEgASgLMhguZmluZGlhcn'
        'kudjEuVHJhbnNhY3Rpb25SC3RyYW5zYWN0aW9u');

@$core.Deprecated('Use updateTransactionRequestDescriptor instead')
const UpdateTransactionRequest$json = {
  '1': 'UpdateTransactionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'amount', '3': 3, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'category_id', '3': 5, '4': 1, '5': 9, '10': 'categoryId'},
    {
      '1': 'description',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'description',
      '17': true
    },
    {'1': 'date', '3': 7, '4': 1, '5': 9, '10': 'date'},
  ],
  '8': [
    {'1': '_description'},
  ],
};

/// Descriptor for `UpdateTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTransactionRequestDescriptor = $convert.base64Decode(
    'ChhVcGRhdGVUcmFuc2FjdGlvblJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhIKBHR5cGUYAiABKA'
    'lSBHR5cGUSFgoGYW1vdW50GAMgASgBUgZhbW91bnQSGgoIY3VycmVuY3kYBCABKAlSCGN1cnJl'
    'bmN5Eh8KC2NhdGVnb3J5X2lkGAUgASgJUgpjYXRlZ29yeUlkEiUKC2Rlc2NyaXB0aW9uGAYgAS'
    'gJSABSC2Rlc2NyaXB0aW9uiAEBEhIKBGRhdGUYByABKAlSBGRhdGVCDgoMX2Rlc2NyaXB0aW9u');

@$core.Deprecated('Use updateTransactionResponseDescriptor instead')
const UpdateTransactionResponse$json = {
  '1': 'UpdateTransactionResponse',
  '2': [
    {
      '1': 'transaction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Transaction',
      '10': 'transaction'
    },
  ],
};

/// Descriptor for `UpdateTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateTransactionResponseDescriptor =
    $convert.base64Decode(
        'ChlVcGRhdGVUcmFuc2FjdGlvblJlc3BvbnNlEjoKC3RyYW5zYWN0aW9uGAEgASgLMhguZmluZG'
        'lhcnkudjEuVHJhbnNhY3Rpb25SC3RyYW5zYWN0aW9u');

@$core.Deprecated('Use deleteTransactionRequestDescriptor instead')
const DeleteTransactionRequest$json = {
  '1': 'DeleteTransactionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteTransactionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTransactionRequestDescriptor = $convert
    .base64Decode('ChhEZWxldGVUcmFuc2FjdGlvblJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use deleteTransactionResponseDescriptor instead')
const DeleteTransactionResponse$json = {
  '1': 'DeleteTransactionResponse',
};

/// Descriptor for `DeleteTransactionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTransactionResponseDescriptor =
    $convert.base64Decode('ChlEZWxldGVUcmFuc2FjdGlvblJlc3BvbnNl');

@$core.Deprecated('Use listTransactionsRequestDescriptor instead')
const ListTransactionsRequest$json = {
  '1': 'ListTransactionsRequest',
  '2': [
    {
      '1': 'family_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'category_id', '3': 3, '4': 1, '5': 9, '10': 'categoryId'},
    {'1': 'start_date', '3': 4, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 5, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 5, '10': 'pageToken'},
  ],
  '8': [
    {'1': '_family_id'},
  ],
};

/// Descriptor for `ListTransactionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0VHJhbnNhY3Rpb25zUmVxdWVzdBIgCglmYW1pbHlfaWQYASABKAlIAFIIZmFtaWx5SW'
    'SIAQESEgoEdHlwZRgCIAEoCVIEdHlwZRIfCgtjYXRlZ29yeV9pZBgDIAEoCVIKY2F0ZWdvcnlJ'
    'ZBIdCgpzdGFydF9kYXRlGAQgASgJUglzdGFydERhdGUSGQoIZW5kX2RhdGUYBSABKAlSB2VuZE'
    'RhdGUSGwoJcGFnZV9zaXplGAYgASgFUghwYWdlU2l6ZRIdCgpwYWdlX3Rva2VuGAcgASgFUglw'
    'YWdlVG9rZW5CDAoKX2ZhbWlseV9pZA==');

@$core.Deprecated('Use listTransactionsResponseDescriptor instead')
const ListTransactionsResponse$json = {
  '1': 'ListTransactionsResponse',
  '2': [
    {
      '1': 'transactions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.Transaction',
      '10': 'transactions'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
    {'1': 'next_page_token', '3': 3, '4': 1, '5': 5, '10': 'nextPageToken'},
  ],
};

/// Descriptor for `ListTransactionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTransactionsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0VHJhbnNhY3Rpb25zUmVzcG9uc2USPAoMdHJhbnNhY3Rpb25zGAEgAygLMhguZmluZG'
    'lhcnkudjEuVHJhbnNhY3Rpb25SDHRyYW5zYWN0aW9ucxIUCgV0b3RhbBgCIAEoBVIFdG90YWwS'
    'JgoPbmV4dF9wYWdlX3Rva2VuGAMgASgFUg1uZXh0UGFnZVRva2Vu');
