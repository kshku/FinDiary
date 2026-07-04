// This is a generated file - do not edit.
//
// Generated from findiary/v1/transaction_service.proto.

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

import 'transaction_service.pb.dart' as $0;

export 'transaction_service.pb.dart';

@$pb.GrpcServiceName('findiary.v1.TransactionService')
class TransactionServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  TransactionServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.CreateTransactionResponse> createTransaction(
    $0.CreateTransactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetTransactionResponse> getTransaction(
    $0.GetTransactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.UpdateTransactionResponse> updateTransaction(
    $0.UpdateTransactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeleteTransactionResponse> deleteTransaction(
    $0.DeleteTransactionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListTransactionsResponse> listTransactions(
    $0.ListTransactionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }

  // method descriptors

  static final _$createTransaction = $grpc.ClientMethod<
          $0.CreateTransactionRequest, $0.CreateTransactionResponse>(
      '/findiary.v1.TransactionService/CreateTransaction',
      ($0.CreateTransactionRequest value) => value.writeToBuffer(),
      $0.CreateTransactionResponse.fromBuffer);
  static final _$getTransaction =
      $grpc.ClientMethod<$0.GetTransactionRequest, $0.GetTransactionResponse>(
          '/findiary.v1.TransactionService/GetTransaction',
          ($0.GetTransactionRequest value) => value.writeToBuffer(),
          $0.GetTransactionResponse.fromBuffer);
  static final _$updateTransaction = $grpc.ClientMethod<
          $0.UpdateTransactionRequest, $0.UpdateTransactionResponse>(
      '/findiary.v1.TransactionService/UpdateTransaction',
      ($0.UpdateTransactionRequest value) => value.writeToBuffer(),
      $0.UpdateTransactionResponse.fromBuffer);
  static final _$deleteTransaction = $grpc.ClientMethod<
          $0.DeleteTransactionRequest, $0.DeleteTransactionResponse>(
      '/findiary.v1.TransactionService/DeleteTransaction',
      ($0.DeleteTransactionRequest value) => value.writeToBuffer(),
      $0.DeleteTransactionResponse.fromBuffer);
  static final _$listTransactions = $grpc.ClientMethod<
          $0.ListTransactionsRequest, $0.ListTransactionsResponse>(
      '/findiary.v1.TransactionService/ListTransactions',
      ($0.ListTransactionsRequest value) => value.writeToBuffer(),
      $0.ListTransactionsResponse.fromBuffer);
}

@$pb.GrpcServiceName('findiary.v1.TransactionService')
abstract class TransactionServiceBase extends $grpc.Service {
  $core.String get $name => 'findiary.v1.TransactionService';

  TransactionServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateTransactionRequest,
            $0.CreateTransactionResponse>(
        'CreateTransaction',
        createTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateTransactionRequest.fromBuffer(value),
        ($0.CreateTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTransactionRequest,
            $0.GetTransactionResponse>(
        'GetTransaction',
        getTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetTransactionRequest.fromBuffer(value),
        ($0.GetTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateTransactionRequest,
            $0.UpdateTransactionResponse>(
        'UpdateTransaction',
        updateTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateTransactionRequest.fromBuffer(value),
        ($0.UpdateTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteTransactionRequest,
            $0.DeleteTransactionResponse>(
        'DeleteTransaction',
        deleteTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteTransactionRequest.fromBuffer(value),
        ($0.DeleteTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTransactionsRequest,
            $0.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListTransactionsRequest.fromBuffer(value),
        ($0.ListTransactionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.CreateTransactionResponse> createTransaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.CreateTransactionRequest> $request) async {
    return createTransaction($call, await $request);
  }

  $async.Future<$0.CreateTransactionResponse> createTransaction(
      $grpc.ServiceCall call, $0.CreateTransactionRequest request);

  $async.Future<$0.GetTransactionResponse> getTransaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetTransactionRequest> $request) async {
    return getTransaction($call, await $request);
  }

  $async.Future<$0.GetTransactionResponse> getTransaction(
      $grpc.ServiceCall call, $0.GetTransactionRequest request);

  $async.Future<$0.UpdateTransactionResponse> updateTransaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.UpdateTransactionRequest> $request) async {
    return updateTransaction($call, await $request);
  }

  $async.Future<$0.UpdateTransactionResponse> updateTransaction(
      $grpc.ServiceCall call, $0.UpdateTransactionRequest request);

  $async.Future<$0.DeleteTransactionResponse> deleteTransaction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeleteTransactionRequest> $request) async {
    return deleteTransaction($call, await $request);
  }

  $async.Future<$0.DeleteTransactionResponse> deleteTransaction(
      $grpc.ServiceCall call, $0.DeleteTransactionRequest request);

  $async.Future<$0.ListTransactionsResponse> listTransactions_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ListTransactionsRequest> $request) async {
    return listTransactions($call, await $request);
  }

  $async.Future<$0.ListTransactionsResponse> listTransactions(
      $grpc.ServiceCall call, $0.ListTransactionsRequest request);
}
