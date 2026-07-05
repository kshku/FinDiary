// This is a generated file - do not edit.
//
// Generated from findiary/v1/sync_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class SyncRequest extends $pb.GeneratedMessage {
  factory SyncRequest({
    $core.String? scopeId,
    $core.String? scopeType,
    $fixnum.Int64? lastCheckpoint,
    $core.Iterable<SyncChangeEntry>? localChanges,
  }) {
    final result = create();
    if (scopeId != null) result.scopeId = scopeId;
    if (scopeType != null) result.scopeType = scopeType;
    if (lastCheckpoint != null) result.lastCheckpoint = lastCheckpoint;
    if (localChanges != null) result.localChanges.addAll(localChanges);
    return result;
  }

  SyncRequest._();

  factory SyncRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'scopeId')
    ..aOS(2, _omitFieldNames ? '' : 'scopeType')
    ..aInt64(3, _omitFieldNames ? '' : 'lastCheckpoint')
    ..pPM<SyncChangeEntry>(4, _omitFieldNames ? '' : 'localChanges',
        subBuilder: SyncChangeEntry.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncRequest copyWith(void Function(SyncRequest) updates) =>
      super.copyWith((message) => updates(message as SyncRequest))
          as SyncRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncRequest create() => SyncRequest._();
  @$core.override
  SyncRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncRequest>(create);
  static SyncRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get scopeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set scopeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScopeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearScopeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get scopeType => $_getSZ(1);
  @$pb.TagNumber(2)
  set scopeType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScopeType() => $_has(1);
  @$pb.TagNumber(2)
  void clearScopeType() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get lastCheckpoint => $_getI64(2);
  @$pb.TagNumber(3)
  set lastCheckpoint($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastCheckpoint() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastCheckpoint() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<SyncChangeEntry> get localChanges => $_getList(3);
}

class SyncResponse extends $pb.GeneratedMessage {
  factory SyncResponse({
    $fixnum.Int64? newCheckpoint,
    $core.Iterable<SyncChangeEntry>? remoteChanges,
    $core.Iterable<ConflictInfo>? conflicts,
  }) {
    final result = create();
    if (newCheckpoint != null) result.newCheckpoint = newCheckpoint;
    if (remoteChanges != null) result.remoteChanges.addAll(remoteChanges);
    if (conflicts != null) result.conflicts.addAll(conflicts);
    return result;
  }

  SyncResponse._();

  factory SyncResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'newCheckpoint')
    ..pPM<SyncChangeEntry>(2, _omitFieldNames ? '' : 'remoteChanges',
        subBuilder: SyncChangeEntry.create)
    ..pPM<ConflictInfo>(3, _omitFieldNames ? '' : 'conflicts',
        subBuilder: ConflictInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncResponse copyWith(void Function(SyncResponse) updates) =>
      super.copyWith((message) => updates(message as SyncResponse))
          as SyncResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncResponse create() => SyncResponse._();
  @$core.override
  SyncResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncResponse>(create);
  static SyncResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get newCheckpoint => $_getI64(0);
  @$pb.TagNumber(1)
  set newCheckpoint($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewCheckpoint() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewCheckpoint() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<SyncChangeEntry> get remoteChanges => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<ConflictInfo> get conflicts => $_getList(2);
}

class SyncChangeEntry extends $pb.GeneratedMessage {
  factory SyncChangeEntry({
    $core.String? entityType,
    $core.String? entityId,
    $core.String? action,
    $core.List<$core.int>? snapshot,
    $1.Timestamp? clientTimestamp,
    $core.Iterable<$core.String>? changedFields,
  }) {
    final result = create();
    if (entityType != null) result.entityType = entityType;
    if (entityId != null) result.entityId = entityId;
    if (action != null) result.action = action;
    if (snapshot != null) result.snapshot = snapshot;
    if (clientTimestamp != null) result.clientTimestamp = clientTimestamp;
    if (changedFields != null) result.changedFields.addAll(changedFields);
    return result;
  }

  SyncChangeEntry._();

  factory SyncChangeEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SyncChangeEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SyncChangeEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entityType')
    ..aOS(2, _omitFieldNames ? '' : 'entityId')
    ..aOS(3, _omitFieldNames ? '' : 'action')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'snapshot', $pb.PbFieldType.OY)
    ..aOM<$1.Timestamp>(5, _omitFieldNames ? '' : 'clientTimestamp',
        subBuilder: $1.Timestamp.create)
    ..pPS(6, _omitFieldNames ? '' : 'changedFields')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncChangeEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncChangeEntry copyWith(void Function(SyncChangeEntry) updates) =>
      super.copyWith((message) => updates(message as SyncChangeEntry))
          as SyncChangeEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncChangeEntry create() => SyncChangeEntry._();
  @$core.override
  SyncChangeEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SyncChangeEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SyncChangeEntry>(create);
  static SyncChangeEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityType => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntityType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get action => $_getSZ(2);
  @$pb.TagNumber(3)
  set action($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAction() => $_has(2);
  @$pb.TagNumber(3)
  void clearAction() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get snapshot => $_getN(3);
  @$pb.TagNumber(4)
  set snapshot($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSnapshot() => $_has(3);
  @$pb.TagNumber(4)
  void clearSnapshot() => $_clearField(4);

  @$pb.TagNumber(5)
  $1.Timestamp get clientTimestamp => $_getN(4);
  @$pb.TagNumber(5)
  set clientTimestamp($1.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasClientTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientTimestamp() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.Timestamp ensureClientTimestamp() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get changedFields => $_getList(5);
}

class ConflictInfo extends $pb.GeneratedMessage {
  factory ConflictInfo({
    $core.String? entityType,
    $core.String? entityId,
    $core.String? field_3,
    $core.String? localValue,
    $core.String? serverValue,
  }) {
    final result = create();
    if (entityType != null) result.entityType = entityType;
    if (entityId != null) result.entityId = entityId;
    if (field_3 != null) result.field_3 = field_3;
    if (localValue != null) result.localValue = localValue;
    if (serverValue != null) result.serverValue = serverValue;
    return result;
  }

  ConflictInfo._();

  factory ConflictInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConflictInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConflictInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entityType')
    ..aOS(2, _omitFieldNames ? '' : 'entityId')
    ..aOS(3, _omitFieldNames ? '' : 'field')
    ..aOS(4, _omitFieldNames ? '' : 'localValue')
    ..aOS(5, _omitFieldNames ? '' : 'serverValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConflictInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConflictInfo copyWith(void Function(ConflictInfo) updates) =>
      super.copyWith((message) => updates(message as ConflictInfo))
          as ConflictInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConflictInfo create() => ConflictInfo._();
  @$core.override
  ConflictInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConflictInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConflictInfo>(create);
  static ConflictInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityType => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntityType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityId => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get field_3 => $_getSZ(2);
  @$pb.TagNumber(3)
  set field_3($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasField_3() => $_has(2);
  @$pb.TagNumber(3)
  void clearField_3() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get localValue => $_getSZ(3);
  @$pb.TagNumber(4)
  set localValue($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocalValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get serverValue => $_getSZ(4);
  @$pb.TagNumber(5)
  set serverValue($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasServerValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearServerValue() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
