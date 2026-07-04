// This is a generated file - do not edit.
//
// Generated from findiary/v1/transaction_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CreateTransactionRequest extends $pb.GeneratedMessage {
  factory CreateTransactionRequest({
    $core.String? familyId,
    $core.String? type,
    $core.double? amount,
    $core.String? currency,
    $core.String? categoryId,
    $core.String? description,
    $core.String? date,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    if (type != null) result.type = type;
    if (amount != null) result.amount = amount;
    if (currency != null) result.currency = currency;
    if (categoryId != null) result.categoryId = categoryId;
    if (description != null) result.description = description;
    if (date != null) result.date = date;
    return result;
  }

  CreateTransactionRequest._();

  factory CreateTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aD(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aOS(5, _omitFieldNames ? '' : 'categoryId')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'date')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTransactionRequest copyWith(
          void Function(CreateTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTransactionRequest))
          as CreateTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTransactionRequest create() => CreateTransactionRequest._();
  @$core.override
  CreateTransactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTransactionRequest>(create);
  static CreateTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get categoryId => $_getSZ(4);
  @$pb.TagNumber(5)
  set categoryId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCategoryId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategoryId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get date => $_getSZ(6);
  @$pb.TagNumber(7)
  set date($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearDate() => $_clearField(7);
}

class CreateTransactionResponse extends $pb.GeneratedMessage {
  factory CreateTransactionResponse({
    $1.Transaction? transaction,
  }) {
    final result = create();
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  CreateTransactionResponse._();

  factory CreateTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Transaction>(1, _omitFieldNames ? '' : 'transaction',
        subBuilder: $1.Transaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTransactionResponse copyWith(
          void Function(CreateTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateTransactionResponse))
          as CreateTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTransactionResponse create() => CreateTransactionResponse._();
  @$core.override
  CreateTransactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateTransactionResponse>(create);
  static CreateTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Transaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction($1.Transaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Transaction ensureTransaction() => $_ensure(0);
}

class GetTransactionRequest extends $pb.GeneratedMessage {
  factory GetTransactionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetTransactionRequest._();

  factory GetTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionRequest copyWith(
          void Function(GetTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionRequest))
          as GetTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest create() => GetTransactionRequest._();
  @$core.override
  GetTransactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionRequest>(create);
  static GetTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetTransactionResponse extends $pb.GeneratedMessage {
  factory GetTransactionResponse({
    $1.Transaction? transaction,
  }) {
    final result = create();
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  GetTransactionResponse._();

  factory GetTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Transaction>(1, _omitFieldNames ? '' : 'transaction',
        subBuilder: $1.Transaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionResponse copyWith(
          void Function(GetTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as GetTransactionResponse))
          as GetTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse create() => GetTransactionResponse._();
  @$core.override
  GetTransactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionResponse>(create);
  static GetTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Transaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction($1.Transaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Transaction ensureTransaction() => $_ensure(0);
}

class UpdateTransactionRequest extends $pb.GeneratedMessage {
  factory UpdateTransactionRequest({
    $core.String? id,
    $core.String? type,
    $core.double? amount,
    $core.String? currency,
    $core.String? categoryId,
    $core.String? description,
    $core.String? date,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (amount != null) result.amount = amount;
    if (currency != null) result.currency = currency;
    if (categoryId != null) result.categoryId = categoryId;
    if (description != null) result.description = description;
    if (date != null) result.date = date;
    return result;
  }

  UpdateTransactionRequest._();

  factory UpdateTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aD(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..aOS(5, _omitFieldNames ? '' : 'categoryId')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'date')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTransactionRequest copyWith(
          void Function(UpdateTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateTransactionRequest))
          as UpdateTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTransactionRequest create() => UpdateTransactionRequest._();
  @$core.override
  UpdateTransactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTransactionRequest>(create);
  static UpdateTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get categoryId => $_getSZ(4);
  @$pb.TagNumber(5)
  set categoryId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCategoryId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategoryId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get date => $_getSZ(6);
  @$pb.TagNumber(7)
  set date($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearDate() => $_clearField(7);
}

class UpdateTransactionResponse extends $pb.GeneratedMessage {
  factory UpdateTransactionResponse({
    $1.Transaction? transaction,
  }) {
    final result = create();
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  UpdateTransactionResponse._();

  factory UpdateTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Transaction>(1, _omitFieldNames ? '' : 'transaction',
        subBuilder: $1.Transaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateTransactionResponse copyWith(
          void Function(UpdateTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateTransactionResponse))
          as UpdateTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateTransactionResponse create() => UpdateTransactionResponse._();
  @$core.override
  UpdateTransactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateTransactionResponse>(create);
  static UpdateTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Transaction get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction($1.Transaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Transaction ensureTransaction() => $_ensure(0);
}

class DeleteTransactionRequest extends $pb.GeneratedMessage {
  factory DeleteTransactionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteTransactionRequest._();

  factory DeleteTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTransactionRequest copyWith(
          void Function(DeleteTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTransactionRequest))
          as DeleteTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTransactionRequest create() => DeleteTransactionRequest._();
  @$core.override
  DeleteTransactionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTransactionRequest>(create);
  static DeleteTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteTransactionResponse extends $pb.GeneratedMessage {
  factory DeleteTransactionResponse() => create();

  DeleteTransactionResponse._();

  factory DeleteTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTransactionResponse copyWith(
          void Function(DeleteTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteTransactionResponse))
          as DeleteTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTransactionResponse create() => DeleteTransactionResponse._();
  @$core.override
  DeleteTransactionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTransactionResponse>(create);
  static DeleteTransactionResponse? _defaultInstance;
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? familyId,
    $core.String? type,
    $core.String? categoryId,
    $core.String? startDate,
    $core.String? endDate,
    $core.int? pageSize,
    $core.int? pageToken,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    if (type != null) result.type = type;
    if (categoryId != null) result.categoryId = categoryId;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListTransactionsRequest._();

  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'categoryId')
    ..aOS(4, _omitFieldNames ? '' : 'startDate')
    ..aOS(5, _omitFieldNames ? '' : 'endDate')
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aI(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest copyWith(
          void Function(ListTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsRequest))
          as ListTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  @$core.override
  ListTransactionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(create);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get categoryId => $_getSZ(2);
  @$pb.TagNumber(3)
  set categoryId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCategoryId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategoryId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get startDate => $_getSZ(3);
  @$pb.TagNumber(4)
  set startDate($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get endDate => $_getSZ(4);
  @$pb.TagNumber(5)
  set endDate($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEndDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pageToken => $_getIZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<$1.Transaction>? transactions,
    $core.int? total,
    $core.int? nextPageToken,
  }) {
    final result = create();
    if (transactions != null) result.transactions.addAll(transactions);
    if (total != null) result.total = total;
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    return result;
  }

  ListTransactionsResponse._();

  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..pPM<$1.Transaction>(1, _omitFieldNames ? '' : 'transactions',
        subBuilder: $1.Transaction.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..aI(3, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse copyWith(
          void Function(ListTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsResponse))
          as ListTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  @$core.override
  ListTransactionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(create);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Transaction> get transactions => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get nextPageToken => $_getIZ(2);
  @$pb.TagNumber(3)
  set nextPageToken($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNextPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearNextPageToken() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
