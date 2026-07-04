// This is a generated file - do not edit.
//
// Generated from findiary/v1/category_service.proto.

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

@$core.Deprecated('Use createCategoryRequestDescriptor instead')
const CreateCategoryRequest$json = {
  '1': 'CreateCategoryRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'scope', '3': 3, '4': 1, '5': 9, '10': 'scope'},
    {
      '1': 'family_id',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {'1': 'icon', '3': 5, '4': 1, '5': 9, '9': 1, '10': 'icon', '17': true},
    {'1': 'color', '3': 6, '4': 1, '5': 9, '9': 2, '10': 'color', '17': true},
  ],
  '8': [
    {'1': '_family_id'},
    {'1': '_icon'},
    {'1': '_color'},
  ],
};

/// Descriptor for `CreateCategoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCategoryRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVDYXRlZ29yeVJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRISCgR0eXBlGAIgAS'
    'gJUgR0eXBlEhQKBXNjb3BlGAMgASgJUgVzY29wZRIgCglmYW1pbHlfaWQYBCABKAlIAFIIZmFt'
    'aWx5SWSIAQESFwoEaWNvbhgFIAEoCUgBUgRpY29uiAEBEhkKBWNvbG9yGAYgASgJSAJSBWNvbG'
    '9yiAEBQgwKCl9mYW1pbHlfaWRCBwoFX2ljb25CCAoGX2NvbG9y');

@$core.Deprecated('Use createCategoryResponseDescriptor instead')
const CreateCategoryResponse$json = {
  '1': 'CreateCategoryResponse',
  '2': [
    {
      '1': 'category',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Category',
      '10': 'category'
    },
  ],
};

/// Descriptor for `CreateCategoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCategoryResponseDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVDYXRlZ29yeVJlc3BvbnNlEjEKCGNhdGVnb3J5GAEgASgLMhUuZmluZGlhcnkudj'
        'EuQ2F0ZWdvcnlSCGNhdGVnb3J5');

@$core.Deprecated('Use getCategoryRequestDescriptor instead')
const GetCategoryRequest$json = {
  '1': 'GetCategoryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetCategoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCategoryRequestDescriptor =
    $convert.base64Decode('ChJHZXRDYXRlZ29yeVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getCategoryResponseDescriptor instead')
const GetCategoryResponse$json = {
  '1': 'GetCategoryResponse',
  '2': [
    {
      '1': 'category',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Category',
      '10': 'category'
    },
  ],
};

/// Descriptor for `GetCategoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCategoryResponseDescriptor = $convert.base64Decode(
    'ChNHZXRDYXRlZ29yeVJlc3BvbnNlEjEKCGNhdGVnb3J5GAEgASgLMhUuZmluZGlhcnkudjEuQ2'
    'F0ZWdvcnlSCGNhdGVnb3J5');

@$core.Deprecated('Use updateCategoryRequestDescriptor instead')
const UpdateCategoryRequest$json = {
  '1': 'UpdateCategoryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'icon', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'icon', '17': true},
    {'1': 'color', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'color', '17': true},
  ],
  '8': [
    {'1': '_icon'},
    {'1': '_color'},
  ],
};

/// Descriptor for `UpdateCategoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCategoryRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVDYXRlZ29yeVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG'
    '5hbWUSFwoEaWNvbhgDIAEoCUgAUgRpY29uiAEBEhkKBWNvbG9yGAQgASgJSAFSBWNvbG9yiAEB'
    'QgcKBV9pY29uQggKBl9jb2xvcg==');

@$core.Deprecated('Use updateCategoryResponseDescriptor instead')
const UpdateCategoryResponse$json = {
  '1': 'UpdateCategoryResponse',
  '2': [
    {
      '1': 'category',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.Category',
      '10': 'category'
    },
  ],
};

/// Descriptor for `UpdateCategoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCategoryResponseDescriptor =
    $convert.base64Decode(
        'ChZVcGRhdGVDYXRlZ29yeVJlc3BvbnNlEjEKCGNhdGVnb3J5GAEgASgLMhUuZmluZGlhcnkudj'
        'EuQ2F0ZWdvcnlSCGNhdGVnb3J5');

@$core.Deprecated('Use deleteCategoryRequestDescriptor instead')
const DeleteCategoryRequest$json = {
  '1': 'DeleteCategoryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteCategoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteCategoryRequestDescriptor = $convert
    .base64Decode('ChVEZWxldGVDYXRlZ29yeVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use deleteCategoryResponseDescriptor instead')
const DeleteCategoryResponse$json = {
  '1': 'DeleteCategoryResponse',
};

/// Descriptor for `DeleteCategoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteCategoryResponseDescriptor =
    $convert.base64Decode('ChZEZWxldGVDYXRlZ29yeVJlc3BvbnNl');

@$core.Deprecated('Use listCategoriesRequestDescriptor instead')
const ListCategoriesRequest$json = {
  '1': 'ListCategoriesRequest',
  '2': [
    {'1': 'scope', '3': 1, '4': 1, '5': 9, '10': 'scope'},
    {
      '1': 'family_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'familyId',
      '17': true
    },
    {'1': 'type', '3': 3, '4': 1, '5': 9, '10': 'type'},
  ],
  '8': [
    {'1': '_family_id'},
  ],
};

/// Descriptor for `ListCategoriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCategoriesRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0Q2F0ZWdvcmllc1JlcXVlc3QSFAoFc2NvcGUYASABKAlSBXNjb3BlEiAKCWZhbWlseV'
    '9pZBgCIAEoCUgAUghmYW1pbHlJZIgBARISCgR0eXBlGAMgASgJUgR0eXBlQgwKCl9mYW1pbHlf'
    'aWQ=');

@$core.Deprecated('Use listCategoriesResponseDescriptor instead')
const ListCategoriesResponse$json = {
  '1': 'ListCategoriesResponse',
  '2': [
    {
      '1': 'categories',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.findiary.v1.Category',
      '10': 'categories'
    },
  ],
};

/// Descriptor for `ListCategoriesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCategoriesResponseDescriptor =
    $convert.base64Decode(
        'ChZMaXN0Q2F0ZWdvcmllc1Jlc3BvbnNlEjUKCmNhdGVnb3JpZXMYASADKAsyFS5maW5kaWFyeS'
        '52MS5DYXRlZ29yeVIKY2F0ZWdvcmllcw==');
