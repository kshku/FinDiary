// This is a generated file - do not edit.
//
// Generated from findiary/v1/category_service.proto.

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

class CreateCategoryRequest extends $pb.GeneratedMessage {
  factory CreateCategoryRequest({
    $core.String? name,
    $core.String? type,
    $core.String? scope,
    $core.String? familyId,
    $core.String? icon,
    $core.String? color,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (scope != null) result.scope = scope;
    if (familyId != null) result.familyId = familyId;
    if (icon != null) result.icon = icon;
    if (color != null) result.color = color;
    return result;
  }

  CreateCategoryRequest._();

  factory CreateCategoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCategoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCategoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'scope')
    ..aOS(4, _omitFieldNames ? '' : 'familyId')
    ..aOS(5, _omitFieldNames ? '' : 'icon')
    ..aOS(6, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCategoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCategoryRequest copyWith(
          void Function(CreateCategoryRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCategoryRequest))
          as CreateCategoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCategoryRequest create() => CreateCategoryRequest._();
  @$core.override
  CreateCategoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCategoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCategoryRequest>(create);
  static CreateCategoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scope => $_getSZ(2);
  @$pb.TagNumber(3)
  set scope($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScope() => $_has(2);
  @$pb.TagNumber(3)
  void clearScope() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get familyId => $_getSZ(3);
  @$pb.TagNumber(4)
  set familyId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFamilyId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFamilyId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get icon => $_getSZ(4);
  @$pb.TagNumber(5)
  set icon($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIcon() => $_has(4);
  @$pb.TagNumber(5)
  void clearIcon() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get color => $_getSZ(5);
  @$pb.TagNumber(6)
  set color($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasColor() => $_has(5);
  @$pb.TagNumber(6)
  void clearColor() => $_clearField(6);
}

class CreateCategoryResponse extends $pb.GeneratedMessage {
  factory CreateCategoryResponse({
    $1.Category? category,
  }) {
    final result = create();
    if (category != null) result.category = category;
    return result;
  }

  CreateCategoryResponse._();

  factory CreateCategoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCategoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCategoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Category>(1, _omitFieldNames ? '' : 'category',
        subBuilder: $1.Category.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCategoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCategoryResponse copyWith(
          void Function(CreateCategoryResponse) updates) =>
      super.copyWith((message) => updates(message as CreateCategoryResponse))
          as CreateCategoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCategoryResponse create() => CreateCategoryResponse._();
  @$core.override
  CreateCategoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCategoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCategoryResponse>(create);
  static CreateCategoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Category get category => $_getN(0);
  @$pb.TagNumber(1)
  set category($1.Category value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCategory() => $_has(0);
  @$pb.TagNumber(1)
  void clearCategory() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Category ensureCategory() => $_ensure(0);
}

class GetCategoryRequest extends $pb.GeneratedMessage {
  factory GetCategoryRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetCategoryRequest._();

  factory GetCategoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCategoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCategoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCategoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCategoryRequest copyWith(void Function(GetCategoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetCategoryRequest))
          as GetCategoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCategoryRequest create() => GetCategoryRequest._();
  @$core.override
  GetCategoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCategoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCategoryRequest>(create);
  static GetCategoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetCategoryResponse extends $pb.GeneratedMessage {
  factory GetCategoryResponse({
    $1.Category? category,
  }) {
    final result = create();
    if (category != null) result.category = category;
    return result;
  }

  GetCategoryResponse._();

  factory GetCategoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCategoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCategoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Category>(1, _omitFieldNames ? '' : 'category',
        subBuilder: $1.Category.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCategoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCategoryResponse copyWith(void Function(GetCategoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetCategoryResponse))
          as GetCategoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCategoryResponse create() => GetCategoryResponse._();
  @$core.override
  GetCategoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCategoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCategoryResponse>(create);
  static GetCategoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Category get category => $_getN(0);
  @$pb.TagNumber(1)
  set category($1.Category value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCategory() => $_has(0);
  @$pb.TagNumber(1)
  void clearCategory() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Category ensureCategory() => $_ensure(0);
}

class UpdateCategoryRequest extends $pb.GeneratedMessage {
  factory UpdateCategoryRequest({
    $core.String? id,
    $core.String? name,
    $core.String? icon,
    $core.String? color,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (icon != null) result.icon = icon;
    if (color != null) result.color = color;
    return result;
  }

  UpdateCategoryRequest._();

  factory UpdateCategoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCategoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCategoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'icon')
    ..aOS(4, _omitFieldNames ? '' : 'color')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCategoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCategoryRequest copyWith(
          void Function(UpdateCategoryRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateCategoryRequest))
          as UpdateCategoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCategoryRequest create() => UpdateCategoryRequest._();
  @$core.override
  UpdateCategoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCategoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCategoryRequest>(create);
  static UpdateCategoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get icon => $_getSZ(2);
  @$pb.TagNumber(3)
  set icon($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIcon() => $_has(2);
  @$pb.TagNumber(3)
  void clearIcon() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get color => $_getSZ(3);
  @$pb.TagNumber(4)
  set color($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasColor() => $_has(3);
  @$pb.TagNumber(4)
  void clearColor() => $_clearField(4);
}

class UpdateCategoryResponse extends $pb.GeneratedMessage {
  factory UpdateCategoryResponse({
    $1.Category? category,
  }) {
    final result = create();
    if (category != null) result.category = category;
    return result;
  }

  UpdateCategoryResponse._();

  factory UpdateCategoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCategoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCategoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$1.Category>(1, _omitFieldNames ? '' : 'category',
        subBuilder: $1.Category.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCategoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCategoryResponse copyWith(
          void Function(UpdateCategoryResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateCategoryResponse))
          as UpdateCategoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCategoryResponse create() => UpdateCategoryResponse._();
  @$core.override
  UpdateCategoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCategoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCategoryResponse>(create);
  static UpdateCategoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Category get category => $_getN(0);
  @$pb.TagNumber(1)
  set category($1.Category value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCategory() => $_has(0);
  @$pb.TagNumber(1)
  void clearCategory() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Category ensureCategory() => $_ensure(0);
}

class DeleteCategoryRequest extends $pb.GeneratedMessage {
  factory DeleteCategoryRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteCategoryRequest._();

  factory DeleteCategoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteCategoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteCategoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCategoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCategoryRequest copyWith(
          void Function(DeleteCategoryRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteCategoryRequest))
          as DeleteCategoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteCategoryRequest create() => DeleteCategoryRequest._();
  @$core.override
  DeleteCategoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteCategoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteCategoryRequest>(create);
  static DeleteCategoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteCategoryResponse extends $pb.GeneratedMessage {
  factory DeleteCategoryResponse() => create();

  DeleteCategoryResponse._();

  factory DeleteCategoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteCategoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteCategoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCategoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCategoryResponse copyWith(
          void Function(DeleteCategoryResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteCategoryResponse))
          as DeleteCategoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteCategoryResponse create() => DeleteCategoryResponse._();
  @$core.override
  DeleteCategoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteCategoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteCategoryResponse>(create);
  static DeleteCategoryResponse? _defaultInstance;
}

class ListCategoriesRequest extends $pb.GeneratedMessage {
  factory ListCategoriesRequest({
    $core.String? scope,
    $core.String? familyId,
    $core.String? type,
  }) {
    final result = create();
    if (scope != null) result.scope = scope;
    if (familyId != null) result.familyId = familyId;
    if (type != null) result.type = type;
    return result;
  }

  ListCategoriesRequest._();

  factory ListCategoriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCategoriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCategoriesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'scope')
    ..aOS(2, _omitFieldNames ? '' : 'familyId')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCategoriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCategoriesRequest copyWith(
          void Function(ListCategoriesRequest) updates) =>
      super.copyWith((message) => updates(message as ListCategoriesRequest))
          as ListCategoriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCategoriesRequest create() => ListCategoriesRequest._();
  @$core.override
  ListCategoriesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCategoriesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCategoriesRequest>(create);
  static ListCategoriesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get scope => $_getSZ(0);
  @$pb.TagNumber(1)
  set scope($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScope() => $_has(0);
  @$pb.TagNumber(1)
  void clearScope() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get familyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set familyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFamilyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFamilyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);
}

class ListCategoriesResponse extends $pb.GeneratedMessage {
  factory ListCategoriesResponse({
    $core.Iterable<$1.Category>? categories,
  }) {
    final result = create();
    if (categories != null) result.categories.addAll(categories);
    return result;
  }

  ListCategoriesResponse._();

  factory ListCategoriesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCategoriesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCategoriesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..pPM<$1.Category>(1, _omitFieldNames ? '' : 'categories',
        subBuilder: $1.Category.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCategoriesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCategoriesResponse copyWith(
          void Function(ListCategoriesResponse) updates) =>
      super.copyWith((message) => updates(message as ListCategoriesResponse))
          as ListCategoriesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCategoriesResponse create() => ListCategoriesResponse._();
  @$core.override
  ListCategoriesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCategoriesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCategoriesResponse>(create);
  static ListCategoriesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$1.Category> get categories => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
