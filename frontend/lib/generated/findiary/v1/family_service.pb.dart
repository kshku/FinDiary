// This is a generated file - do not edit.
//
// Generated from findiary/v1/family_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CreateFamilyRequest extends $pb.GeneratedMessage {
  factory CreateFamilyRequest({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  CreateFamilyRequest._();

  factory CreateFamilyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFamilyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFamilyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFamilyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFamilyRequest copyWith(void Function(CreateFamilyRequest) updates) =>
      super.copyWith((message) => updates(message as CreateFamilyRequest))
          as CreateFamilyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFamilyRequest create() => CreateFamilyRequest._();
  @$core.override
  CreateFamilyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFamilyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFamilyRequest>(create);
  static CreateFamilyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class CreateFamilyResponse extends $pb.GeneratedMessage {
  factory CreateFamilyResponse({
    $2.Family? family,
  }) {
    final result = create();
    if (family != null) result.family = family;
    return result;
  }

  CreateFamilyResponse._();

  factory CreateFamilyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFamilyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFamilyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.Family>(1, _omitFieldNames ? '' : 'family',
        subBuilder: $2.Family.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFamilyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFamilyResponse copyWith(void Function(CreateFamilyResponse) updates) =>
      super.copyWith((message) => updates(message as CreateFamilyResponse))
          as CreateFamilyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFamilyResponse create() => CreateFamilyResponse._();
  @$core.override
  CreateFamilyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFamilyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFamilyResponse>(create);
  static CreateFamilyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Family get family => $_getN(0);
  @$pb.TagNumber(1)
  set family($2.Family value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFamily() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamily() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Family ensureFamily() => $_ensure(0);
}

class GetFamilyRequest extends $pb.GeneratedMessage {
  factory GetFamilyRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetFamilyRequest._();

  factory GetFamilyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFamilyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFamilyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFamilyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFamilyRequest copyWith(void Function(GetFamilyRequest) updates) =>
      super.copyWith((message) => updates(message as GetFamilyRequest))
          as GetFamilyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFamilyRequest create() => GetFamilyRequest._();
  @$core.override
  GetFamilyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFamilyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFamilyRequest>(create);
  static GetFamilyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetFamilyResponse extends $pb.GeneratedMessage {
  factory GetFamilyResponse({
    $2.Family? family,
  }) {
    final result = create();
    if (family != null) result.family = family;
    return result;
  }

  GetFamilyResponse._();

  factory GetFamilyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFamilyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFamilyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.Family>(1, _omitFieldNames ? '' : 'family',
        subBuilder: $2.Family.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFamilyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFamilyResponse copyWith(void Function(GetFamilyResponse) updates) =>
      super.copyWith((message) => updates(message as GetFamilyResponse))
          as GetFamilyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFamilyResponse create() => GetFamilyResponse._();
  @$core.override
  GetFamilyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFamilyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFamilyResponse>(create);
  static GetFamilyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Family get family => $_getN(0);
  @$pb.TagNumber(1)
  set family($2.Family value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFamily() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamily() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Family ensureFamily() => $_ensure(0);
}

class UpdateFamilyRequest extends $pb.GeneratedMessage {
  factory UpdateFamilyRequest({
    $core.String? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  UpdateFamilyRequest._();

  factory UpdateFamilyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateFamilyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFamilyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFamilyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFamilyRequest copyWith(void Function(UpdateFamilyRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateFamilyRequest))
          as UpdateFamilyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFamilyRequest create() => UpdateFamilyRequest._();
  @$core.override
  UpdateFamilyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateFamilyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFamilyRequest>(create);
  static UpdateFamilyRequest? _defaultInstance;

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
}

class UpdateFamilyResponse extends $pb.GeneratedMessage {
  factory UpdateFamilyResponse({
    $2.Family? family,
  }) {
    final result = create();
    if (family != null) result.family = family;
    return result;
  }

  UpdateFamilyResponse._();

  factory UpdateFamilyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateFamilyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFamilyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.Family>(1, _omitFieldNames ? '' : 'family',
        subBuilder: $2.Family.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFamilyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFamilyResponse copyWith(void Function(UpdateFamilyResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateFamilyResponse))
          as UpdateFamilyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFamilyResponse create() => UpdateFamilyResponse._();
  @$core.override
  UpdateFamilyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateFamilyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFamilyResponse>(create);
  static UpdateFamilyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Family get family => $_getN(0);
  @$pb.TagNumber(1)
  set family($2.Family value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFamily() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamily() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Family ensureFamily() => $_ensure(0);
}

class ListMyFamiliesResponse extends $pb.GeneratedMessage {
  factory ListMyFamiliesResponse({
    $core.Iterable<$2.Family>? families,
  }) {
    final result = create();
    if (families != null) result.families.addAll(families);
    return result;
  }

  ListMyFamiliesResponse._();

  factory ListMyFamiliesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMyFamiliesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMyFamiliesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..pPM<$2.Family>(1, _omitFieldNames ? '' : 'families',
        subBuilder: $2.Family.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMyFamiliesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMyFamiliesResponse copyWith(
          void Function(ListMyFamiliesResponse) updates) =>
      super.copyWith((message) => updates(message as ListMyFamiliesResponse))
          as ListMyFamiliesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMyFamiliesResponse create() => ListMyFamiliesResponse._();
  @$core.override
  ListMyFamiliesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMyFamiliesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMyFamiliesResponse>(create);
  static ListMyFamiliesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.Family> get families => $_getList(0);
}

class AddMemberRequest extends $pb.GeneratedMessage {
  factory AddMemberRequest({
    $core.String? familyId,
    $core.String? userId,
    $core.String? role,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    if (userId != null) result.userId = userId;
    if (role != null) result.role = role;
    return result;
  }

  AddMemberRequest._();

  factory AddMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'role')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberRequest copyWith(void Function(AddMemberRequest) updates) =>
      super.copyWith((message) => updates(message as AddMemberRequest))
          as AddMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMemberRequest create() => AddMemberRequest._();
  @$core.override
  AddMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMemberRequest>(create);
  static AddMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get role => $_getSZ(2);
  @$pb.TagNumber(3)
  set role($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearRole() => $_clearField(3);
}

class AddMemberResponse extends $pb.GeneratedMessage {
  factory AddMemberResponse({
    $2.FamilyMember? member,
  }) {
    final result = create();
    if (member != null) result.member = member;
    return result;
  }

  AddMemberResponse._();

  factory AddMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.FamilyMember>(1, _omitFieldNames ? '' : 'member',
        subBuilder: $2.FamilyMember.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddMemberResponse copyWith(void Function(AddMemberResponse) updates) =>
      super.copyWith((message) => updates(message as AddMemberResponse))
          as AddMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMemberResponse create() => AddMemberResponse._();
  @$core.override
  AddMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddMemberResponse>(create);
  static AddMemberResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.FamilyMember get member => $_getN(0);
  @$pb.TagNumber(1)
  set member($2.FamilyMember value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMember() => $_has(0);
  @$pb.TagNumber(1)
  void clearMember() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.FamilyMember ensureMember() => $_ensure(0);
}

class RemoveMemberRequest extends $pb.GeneratedMessage {
  factory RemoveMemberRequest({
    $core.String? familyId,
    $core.String? userId,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    if (userId != null) result.userId = userId;
    return result;
  }

  RemoveMemberRequest._();

  factory RemoveMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..aOS(2, _omitFieldNames ? '' : 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMemberRequest copyWith(void Function(RemoveMemberRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveMemberRequest))
          as RemoveMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveMemberRequest create() => RemoveMemberRequest._();
  @$core.override
  RemoveMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveMemberRequest>(create);
  static RemoveMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);
}

class RemoveMemberResponse extends $pb.GeneratedMessage {
  factory RemoveMemberResponse() => create();

  RemoveMemberResponse._();

  factory RemoveMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RemoveMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RemoveMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveMemberResponse copyWith(void Function(RemoveMemberResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveMemberResponse))
          as RemoveMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RemoveMemberResponse create() => RemoveMemberResponse._();
  @$core.override
  RemoveMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RemoveMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveMemberResponse>(create);
  static RemoveMemberResponse? _defaultInstance;
}

class InviteMemberRequest extends $pb.GeneratedMessage {
  factory InviteMemberRequest({
    $core.String? familyId,
    $core.String? email,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    if (email != null) result.email = email;
    return result;
  }

  InviteMemberRequest._();

  factory InviteMemberRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteMemberRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteMemberRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..aOS(2, _omitFieldNames ? '' : 'email')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMemberRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMemberRequest copyWith(void Function(InviteMemberRequest) updates) =>
      super.copyWith((message) => updates(message as InviteMemberRequest))
          as InviteMemberRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteMemberRequest create() => InviteMemberRequest._();
  @$core.override
  InviteMemberRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteMemberRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteMemberRequest>(create);
  static InviteMemberRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => $_clearField(2);
}

class InviteMemberResponse extends $pb.GeneratedMessage {
  factory InviteMemberResponse({
    $2.Invitation? invitation,
  }) {
    final result = create();
    if (invitation != null) result.invitation = invitation;
    return result;
  }

  InviteMemberResponse._();

  factory InviteMemberResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InviteMemberResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InviteMemberResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.Invitation>(1, _omitFieldNames ? '' : 'invitation',
        subBuilder: $2.Invitation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMemberResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InviteMemberResponse copyWith(void Function(InviteMemberResponse) updates) =>
      super.copyWith((message) => updates(message as InviteMemberResponse))
          as InviteMemberResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InviteMemberResponse create() => InviteMemberResponse._();
  @$core.override
  InviteMemberResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InviteMemberResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InviteMemberResponse>(create);
  static InviteMemberResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Invitation get invitation => $_getN(0);
  @$pb.TagNumber(1)
  set invitation($2.Invitation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInvitation() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvitation() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Invitation ensureInvitation() => $_ensure(0);
}

class AcceptInvitationRequest extends $pb.GeneratedMessage {
  factory AcceptInvitationRequest({
    $core.String? code,
  }) {
    final result = create();
    if (code != null) result.code = code;
    return result;
  }

  AcceptInvitationRequest._();

  factory AcceptInvitationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcceptInvitationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcceptInvitationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptInvitationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptInvitationRequest copyWith(
          void Function(AcceptInvitationRequest) updates) =>
      super.copyWith((message) => updates(message as AcceptInvitationRequest))
          as AcceptInvitationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptInvitationRequest create() => AcceptInvitationRequest._();
  @$core.override
  AcceptInvitationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcceptInvitationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcceptInvitationRequest>(create);
  static AcceptInvitationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);
}

class AcceptInvitationResponse extends $pb.GeneratedMessage {
  factory AcceptInvitationResponse({
    $2.FamilyMember? member,
  }) {
    final result = create();
    if (member != null) result.member = member;
    return result;
  }

  AcceptInvitationResponse._();

  factory AcceptInvitationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcceptInvitationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcceptInvitationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.FamilyMember>(1, _omitFieldNames ? '' : 'member',
        subBuilder: $2.FamilyMember.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptInvitationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcceptInvitationResponse copyWith(
          void Function(AcceptInvitationResponse) updates) =>
      super.copyWith((message) => updates(message as AcceptInvitationResponse))
          as AcceptInvitationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcceptInvitationResponse create() => AcceptInvitationResponse._();
  @$core.override
  AcceptInvitationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcceptInvitationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcceptInvitationResponse>(create);
  static AcceptInvitationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.FamilyMember get member => $_getN(0);
  @$pb.TagNumber(1)
  set member($2.FamilyMember value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMember() => $_has(0);
  @$pb.TagNumber(1)
  void clearMember() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.FamilyMember ensureMember() => $_ensure(0);
}

class RevokeInvitationRequest extends $pb.GeneratedMessage {
  factory RevokeInvitationRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  RevokeInvitationRequest._();

  factory RevokeInvitationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeInvitationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeInvitationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeInvitationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeInvitationRequest copyWith(
          void Function(RevokeInvitationRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeInvitationRequest))
          as RevokeInvitationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeInvitationRequest create() => RevokeInvitationRequest._();
  @$core.override
  RevokeInvitationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeInvitationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeInvitationRequest>(create);
  static RevokeInvitationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class RevokeInvitationResponse extends $pb.GeneratedMessage {
  factory RevokeInvitationResponse({
    $2.Invitation? invitation,
  }) {
    final result = create();
    if (invitation != null) result.invitation = invitation;
    return result;
  }

  RevokeInvitationResponse._();

  factory RevokeInvitationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeInvitationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RevokeInvitationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOM<$2.Invitation>(1, _omitFieldNames ? '' : 'invitation',
        subBuilder: $2.Invitation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeInvitationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeInvitationResponse copyWith(
          void Function(RevokeInvitationResponse) updates) =>
      super.copyWith((message) => updates(message as RevokeInvitationResponse))
          as RevokeInvitationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeInvitationResponse create() => RevokeInvitationResponse._();
  @$core.override
  RevokeInvitationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeInvitationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RevokeInvitationResponse>(create);
  static RevokeInvitationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $2.Invitation get invitation => $_getN(0);
  @$pb.TagNumber(1)
  set invitation($2.Invitation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInvitation() => $_has(0);
  @$pb.TagNumber(1)
  void clearInvitation() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.Invitation ensureInvitation() => $_ensure(0);
}

class ListInvitationsRequest extends $pb.GeneratedMessage {
  factory ListInvitationsRequest({
    $core.String? familyId,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    return result;
  }

  ListInvitationsRequest._();

  factory ListInvitationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInvitationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInvitationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInvitationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInvitationsRequest copyWith(
          void Function(ListInvitationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListInvitationsRequest))
          as ListInvitationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInvitationsRequest create() => ListInvitationsRequest._();
  @$core.override
  ListInvitationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInvitationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInvitationsRequest>(create);
  static ListInvitationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);
}

class ListInvitationsResponse extends $pb.GeneratedMessage {
  factory ListInvitationsResponse({
    $core.Iterable<$2.Invitation>? invitations,
  }) {
    final result = create();
    if (invitations != null) result.invitations.addAll(invitations);
    return result;
  }

  ListInvitationsResponse._();

  factory ListInvitationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInvitationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInvitationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..pPM<$2.Invitation>(1, _omitFieldNames ? '' : 'invitations',
        subBuilder: $2.Invitation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInvitationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInvitationsResponse copyWith(
          void Function(ListInvitationsResponse) updates) =>
      super.copyWith((message) => updates(message as ListInvitationsResponse))
          as ListInvitationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInvitationsResponse create() => ListInvitationsResponse._();
  @$core.override
  ListInvitationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInvitationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInvitationsResponse>(create);
  static ListInvitationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.Invitation> get invitations => $_getList(0);
}

class ListMembersRequest extends $pb.GeneratedMessage {
  factory ListMembersRequest({
    $core.String? familyId,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    return result;
  }

  ListMembersRequest._();

  factory ListMembersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMembersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMembersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersRequest copyWith(void Function(ListMembersRequest) updates) =>
      super.copyWith((message) => updates(message as ListMembersRequest))
          as ListMembersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMembersRequest create() => ListMembersRequest._();
  @$core.override
  ListMembersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMembersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMembersRequest>(create);
  static ListMembersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);
}

class ListMembersResponse extends $pb.GeneratedMessage {
  factory ListMembersResponse({
    $core.Iterable<$2.FamilyMember>? members,
  }) {
    final result = create();
    if (members != null) result.members.addAll(members);
    return result;
  }

  ListMembersResponse._();

  factory ListMembersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMembersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMembersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..pPM<$2.FamilyMember>(1, _omitFieldNames ? '' : 'members',
        subBuilder: $2.FamilyMember.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMembersResponse copyWith(void Function(ListMembersResponse) updates) =>
      super.copyWith((message) => updates(message as ListMembersResponse))
          as ListMembersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMembersResponse create() => ListMembersResponse._();
  @$core.override
  ListMembersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMembersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMembersResponse>(create);
  static ListMembersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$2.FamilyMember> get members => $_getList(0);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
