// This is a generated file - do not edit.
//
// Generated from findiary/v1/category_service.proto.

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

import 'category_service.pb.dart' as $0;

export 'category_service.pb.dart';

@$pb.GrpcServiceName('findiary.v1.CategoryService')
class CategoryServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  CategoryServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CreateCategoryResponse> createCategory(
    $0.CreateCategoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createCategory, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetCategoryResponse> getCategory(
    $0.GetCategoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCategory, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateCategoryResponse> updateCategory(
    $0.UpdateCategoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateCategory, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteCategoryResponse> deleteCategory(
    $0.DeleteCategoryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteCategory, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListCategoriesResponse> listCategories(
    $0.ListCategoriesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listCategories, request, options: options);
  }

  // method descriptors

  static final _$createCategory =
      $grpc.ClientMethod<$0.CreateCategoryRequest, $0.CreateCategoryResponse>(
          '/findiary.v1.CategoryService/CreateCategory',
          ($0.CreateCategoryRequest value) => value.writeToBuffer(),
          $0.CreateCategoryResponse.fromBuffer);
  static final _$getCategory =
      $grpc.ClientMethod<$0.GetCategoryRequest, $0.GetCategoryResponse>(
          '/findiary.v1.CategoryService/GetCategory',
          ($0.GetCategoryRequest value) => value.writeToBuffer(),
          $0.GetCategoryResponse.fromBuffer);
  static final _$updateCategory =
      $grpc.ClientMethod<$0.UpdateCategoryRequest, $0.UpdateCategoryResponse>(
          '/findiary.v1.CategoryService/UpdateCategory',
          ($0.UpdateCategoryRequest value) => value.writeToBuffer(),
          $0.UpdateCategoryResponse.fromBuffer);
  static final _$deleteCategory =
      $grpc.ClientMethod<$0.DeleteCategoryRequest, $0.DeleteCategoryResponse>(
          '/findiary.v1.CategoryService/DeleteCategory',
          ($0.DeleteCategoryRequest value) => value.writeToBuffer(),
          $0.DeleteCategoryResponse.fromBuffer);
  static final _$listCategories =
      $grpc.ClientMethod<$0.ListCategoriesRequest, $0.ListCategoriesResponse>(
          '/findiary.v1.CategoryService/ListCategories',
          ($0.ListCategoriesRequest value) => value.writeToBuffer(),
          $0.ListCategoriesResponse.fromBuffer);
}

@$pb.GrpcServiceName('findiary.v1.CategoryService')
abstract class CategoryServiceBase extends $grpc.Service {
  $core.String get $name => 'findiary.v1.CategoryService';

  CategoryServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateCategoryRequest,
            $0.CreateCategoryResponse>(
        'CreateCategory',
        createCategory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateCategoryRequest.fromBuffer(value),
        ($0.CreateCategoryResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetCategoryRequest, $0.GetCategoryResponse>(
            'GetCategory',
            getCategory_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetCategoryRequest.fromBuffer(value),
            ($0.GetCategoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateCategoryRequest,
            $0.UpdateCategoryResponse>(
        'UpdateCategory',
        updateCategory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateCategoryRequest.fromBuffer(value),
        ($0.UpdateCategoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteCategoryRequest,
            $0.DeleteCategoryResponse>(
        'DeleteCategory',
        deleteCategory_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteCategoryRequest.fromBuffer(value),
        ($0.DeleteCategoryResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListCategoriesRequest,
            $0.ListCategoriesResponse>(
        'ListCategories',
        listCategories_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListCategoriesRequest.fromBuffer(value),
        ($0.ListCategoriesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateCategoryResponse> createCategory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateCategoryRequest> $request) async {
    return createCategory($call, await $request);
  }

  $async.Future<$0.CreateCategoryResponse> createCategory(
      $grpc.ServiceCall call, $0.CreateCategoryRequest request);

  $async.Future<$0.GetCategoryResponse> getCategory_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetCategoryRequest> $request) async {
    return getCategory($call, await $request);
  }

  $async.Future<$0.GetCategoryResponse> getCategory(
      $grpc.ServiceCall call, $0.GetCategoryRequest request);

  $async.Future<$0.UpdateCategoryResponse> updateCategory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateCategoryRequest> $request) async {
    return updateCategory($call, await $request);
  }

  $async.Future<$0.UpdateCategoryResponse> updateCategory(
      $grpc.ServiceCall call, $0.UpdateCategoryRequest request);

  $async.Future<$0.DeleteCategoryResponse> deleteCategory_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteCategoryRequest> $request) async {
    return deleteCategory($call, await $request);
  }

  $async.Future<$0.DeleteCategoryResponse> deleteCategory(
      $grpc.ServiceCall call, $0.DeleteCategoryRequest request);

  $async.Future<$0.ListCategoriesResponse> listCategories_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListCategoriesRequest> $request) async {
    return listCategories($call, await $request);
  }

  $async.Future<$0.ListCategoriesResponse> listCategories(
      $grpc.ServiceCall call, $0.ListCategoriesRequest request);
}
