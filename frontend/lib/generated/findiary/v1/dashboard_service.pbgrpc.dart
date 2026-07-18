// This is a generated file - do not edit.
//
// Generated from findiary/v1/dashboard_service.proto.

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

import 'dashboard_service.pb.dart' as $0;

export 'dashboard_service.pb.dart';

@$pb.GrpcServiceName('findiary.v1.DashboardService')
class DashboardServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  DashboardServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.GetDashboardResponse> getDashboard(
    $0.GetDashboardRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDashboard, request, options: options);
  }

  // method descriptors

  static final _$getDashboard =
      $grpc.ClientMethod<$0.GetDashboardRequest, $0.GetDashboardResponse>(
          '/findiary.v1.DashboardService/GetDashboard',
          ($0.GetDashboardRequest value) => value.writeToBuffer(),
          $0.GetDashboardResponse.fromBuffer);
}

@$pb.GrpcServiceName('findiary.v1.DashboardService')
abstract class DashboardServiceBase extends $grpc.Service {
  $core.String get $name => 'findiary.v1.DashboardService';

  DashboardServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.GetDashboardRequest, $0.GetDashboardResponse>(
            'GetDashboard',
            getDashboard_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetDashboardRequest.fromBuffer(value),
            ($0.GetDashboardResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetDashboardResponse> getDashboard_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDashboardRequest> $request) async {
    return getDashboard($call, await $request);
  }

  $async.Future<$0.GetDashboardResponse> getDashboard(
      $grpc.ServiceCall call, $0.GetDashboardRequest request);
}
