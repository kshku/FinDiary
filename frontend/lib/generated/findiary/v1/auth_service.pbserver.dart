// This is a generated file - do not edit.
//
// Generated from findiary/v1/auth_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'auth_service.pb.dart' as $2;
import 'auth_service.pbjson.dart';

export 'auth_service.pb.dart';

abstract class AuthServiceBase extends $pb.GeneratedService {
  $async.Future<$2.RegisterResponse> register(
      $pb.ServerContext ctx, $2.RegisterRequest request);
  $async.Future<$2.LoginResponse> login(
      $pb.ServerContext ctx, $2.LoginRequest request);
  $async.Future<$2.RefreshTokenResponse> refreshToken(
      $pb.ServerContext ctx, $2.RefreshTokenRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'Register':
        return $2.RegisterRequest();
      case 'Login':
        return $2.LoginRequest();
      case 'RefreshToken':
        return $2.RefreshTokenRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'Register':
        return register(ctx, request as $2.RegisterRequest);
      case 'Login':
        return login(ctx, request as $2.LoginRequest);
      case 'RefreshToken':
        return refreshToken(ctx, request as $2.RefreshTokenRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AuthServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AuthServiceBase$messageJson;
}
