// This is a generated file - do not edit.
//
// Generated from findiary/v1/auth_service.proto.

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

@$core.Deprecated('Use registerRequestDescriptor instead')
const RegisterRequest$json = {
  '1': 'RegisterRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'display_name', '3': 3, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `RegisterRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerRequestDescriptor = $convert.base64Decode(
    'Cg9SZWdpc3RlclJlcXVlc3QSFAoFZW1haWwYASABKAlSBWVtYWlsEhoKCHBhc3N3b3JkGAIgAS'
    'gJUghwYXNzd29yZBIhCgxkaXNwbGF5X25hbWUYAyABKAlSC2Rpc3BsYXlOYW1l');

@$core.Deprecated('Use loginRequestDescriptor instead')
const LoginRequest$json = {
  '1': 'LoginRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `LoginRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginRequestDescriptor = $convert.base64Decode(
    'CgxMb2dpblJlcXVlc3QSFAoFZW1haWwYASABKAlSBWVtYWlsEhoKCHBhc3N3b3JkGAIgASgJUg'
    'hwYXNzd29yZA==');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor = $convert.base64Decode(
    'ChNSZWZyZXNoVG9rZW5SZXF1ZXN0EiMKDXJlZnJlc2hfdG9rZW4YASABKAlSDHJlZnJlc2hUb2'
    'tlbg==');

@$core.Deprecated('Use registerResponseDescriptor instead')
const RegisterResponse$json = {
  '1': 'RegisterResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_expires_at', '3': 3, '4': 1, '5': 3, '10': 'accessExpiresAt'},
    {
      '1': 'refresh_expires_at',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'refreshExpiresAt'
    },
    {
      '1': 'user',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.User',
      '10': 'user'
    },
  ],
};

/// Descriptor for `RegisterResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerResponseDescriptor = $convert.base64Decode(
    'ChBSZWdpc3RlclJlc3BvbnNlEiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SIw'
    'oNcmVmcmVzaF90b2tlbhgCIAEoCVIMcmVmcmVzaFRva2VuEioKEWFjY2Vzc19leHBpcmVzX2F0'
    'GAMgASgDUg9hY2Nlc3NFeHBpcmVzQXQSLAoScmVmcmVzaF9leHBpcmVzX2F0GAQgASgDUhByZW'
    'ZyZXNoRXhwaXJlc0F0EiUKBHVzZXIYBSABKAsyES5maW5kaWFyeS52MS5Vc2VyUgR1c2Vy');

@$core.Deprecated('Use loginResponseDescriptor instead')
const LoginResponse$json = {
  '1': 'LoginResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_expires_at', '3': 3, '4': 1, '5': 3, '10': 'accessExpiresAt'},
    {
      '1': 'refresh_expires_at',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'refreshExpiresAt'
    },
    {
      '1': 'user',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.User',
      '10': 'user'
    },
  ],
};

/// Descriptor for `LoginResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loginResponseDescriptor = $convert.base64Decode(
    'Cg1Mb2dpblJlc3BvbnNlEiEKDGFjY2Vzc190b2tlbhgBIAEoCVILYWNjZXNzVG9rZW4SIwoNcm'
    'VmcmVzaF90b2tlbhgCIAEoCVIMcmVmcmVzaFRva2VuEioKEWFjY2Vzc19leHBpcmVzX2F0GAMg'
    'ASgDUg9hY2Nlc3NFeHBpcmVzQXQSLAoScmVmcmVzaF9leHBpcmVzX2F0GAQgASgDUhByZWZyZX'
    'NoRXhwaXJlc0F0EiUKBHVzZXIYBSABKAsyES5maW5kaWFyeS52MS5Vc2VyUgR1c2Vy');

@$core.Deprecated('Use refreshTokenResponseDescriptor instead')
const RefreshTokenResponse$json = {
  '1': 'RefreshTokenResponse',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_expires_at', '3': 3, '4': 1, '5': 3, '10': 'accessExpiresAt'},
    {
      '1': 'refresh_expires_at',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'refreshExpiresAt'
    },
    {
      '1': 'user',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.findiary.v1.User',
      '10': 'user'
    },
  ],
};

/// Descriptor for `RefreshTokenResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenResponseDescriptor = $convert.base64Decode(
    'ChRSZWZyZXNoVG9rZW5SZXNwb25zZRIhCgxhY2Nlc3NfdG9rZW4YASABKAlSC2FjY2Vzc1Rva2'
    'VuEiMKDXJlZnJlc2hfdG9rZW4YAiABKAlSDHJlZnJlc2hUb2tlbhIqChFhY2Nlc3NfZXhwaXJl'
    'c19hdBgDIAEoA1IPYWNjZXNzRXhwaXJlc0F0EiwKEnJlZnJlc2hfZXhwaXJlc19hdBgEIAEoA1'
    'IQcmVmcmVzaEV4cGlyZXNBdBIlCgR1c2VyGAUgASgLMhEuZmluZGlhcnkudjEuVXNlclIEdXNl'
    'cg==');
