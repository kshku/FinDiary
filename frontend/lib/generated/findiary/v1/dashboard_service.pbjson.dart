// This is a generated file - do not edit.
//
// Generated from findiary/v1/dashboard_service.proto.

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

@$core.Deprecated('Use getDashboardRequestDescriptor instead')
const GetDashboardRequest$json = {
  '1': 'GetDashboardRequest',
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
    {'1': 'months', '3': 2, '4': 1, '5': 5, '10': 'months'},
  ],
  '8': [
    {'1': '_family_id'},
  ],
};

/// Descriptor for `GetDashboardRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDashboardRequestDescriptor = $convert.base64Decode(
    'ChNHZXREYXNoYm9hcmRSZXF1ZXN0EiAKCWZhbWlseV9pZBgBIAEoCUgAUghmYW1pbHlJZIgBAR'
    'IWCgZtb250aHMYAiABKAVSBm1vbnRoc0IMCgpfZmFtaWx5X2lk');

@$core.Deprecated('Use monthlySummaryDescriptor instead')
const MonthlySummary$json = {
  '1': 'MonthlySummary',
  '2': [
    {'1': 'year_month', '3': 1, '4': 1, '5': 9, '10': 'yearMonth'},
    {'1': 'total_income', '3': 2, '4': 1, '5': 1, '10': 'totalIncome'},
    {'1': 'total_expense', '3': 3, '4': 1, '5': 1, '10': 'totalExpense'},
  ],
};

/// Descriptor for `MonthlySummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List monthlySummaryDescriptor = $convert.base64Decode(
    'Cg5Nb250aGx5U3VtbWFyeRIdCgp5ZWFyX21vbnRoGAEgASgJUgl5ZWFyTW9udGgSIQoMdG90YW'
    'xfaW5jb21lGAIgASgBUgt0b3RhbEluY29tZRIjCg10b3RhbF9leHBlbnNlGAMgASgBUgx0b3Rh'
    'bEV4cGVuc2U=');

@$core.Deprecated('Use getDashboardResponseDescriptor instead')
const GetDashboardResponse$json = {
  '1': 'GetDashboardResponse',
  '2': [
    {'1': 'total_income', '3': 1, '4': 1, '5': 1, '10': 'totalIncome'},
    {'1': 'total_expense', '3': 2, '4': 1, '5': 1, '10': 'totalExpense'},
    {
      '1': 'monthly',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.MonthlySummary',
      '10': 'monthly'
    },
    {
      '1': 'recent_transactions',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.Transaction',
      '10': 'recentTransactions'
    },
  ],
};

/// Descriptor for `GetDashboardResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDashboardResponseDescriptor = $convert.base64Decode(
    'ChRHZXREYXNoYm9hcmRSZXNwb25zZRIhCgx0b3RhbF9pbmNvbWUYASABKAFSC3RvdGFsSW5jb2'
    '1lEiMKDXRvdGFsX2V4cGVuc2UYAiABKAFSDHRvdGFsRXhwZW5zZRI1Cgdtb250aGx5GAMgAygL'
    'MhsuZmluZGlhcnkudjEuTW9udGhseVN1bW1hcnlSB21vbnRobHkSSQoTcmVjZW50X3RyYW5zYW'
    'N0aW9ucxgEIAMoCzIYLmZpbmRpYXJ5LnYxLlRyYW5zYWN0aW9uUhJyZWNlbnRUcmFuc2FjdGlv'
    'bnM=');
