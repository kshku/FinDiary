// This is a generated file - do not edit.
//
// Generated from findiary/v1/dashboard_service.proto.

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

class GetDashboardRequest extends $pb.GeneratedMessage {
  factory GetDashboardRequest({
    $core.String? familyId,
    $core.int? months,
  }) {
    final result = create();
    if (familyId != null) result.familyId = familyId;
    if (months != null) result.months = months;
    return result;
  }

  GetDashboardRequest._();

  factory GetDashboardRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDashboardRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDashboardRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'familyId')
    ..aI(2, _omitFieldNames ? '' : 'months')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDashboardRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDashboardRequest copyWith(void Function(GetDashboardRequest) updates) =>
      super.copyWith((message) => updates(message as GetDashboardRequest))
          as GetDashboardRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDashboardRequest create() => GetDashboardRequest._();
  @$core.override
  GetDashboardRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDashboardRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDashboardRequest>(create);
  static GetDashboardRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get familyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set familyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFamilyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFamilyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get months => $_getIZ(1);
  @$pb.TagNumber(2)
  set months($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMonths() => $_has(1);
  @$pb.TagNumber(2)
  void clearMonths() => $_clearField(2);
}

class MonthlySummary extends $pb.GeneratedMessage {
  factory MonthlySummary({
    $core.String? yearMonth,
    $core.double? totalIncome,
    $core.double? totalExpense,
  }) {
    final result = create();
    if (yearMonth != null) result.yearMonth = yearMonth;
    if (totalIncome != null) result.totalIncome = totalIncome;
    if (totalExpense != null) result.totalExpense = totalExpense;
    return result;
  }

  MonthlySummary._();

  factory MonthlySummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MonthlySummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MonthlySummary',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'yearMonth')
    ..aD(2, _omitFieldNames ? '' : 'totalIncome')
    ..aD(3, _omitFieldNames ? '' : 'totalExpense')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MonthlySummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MonthlySummary copyWith(void Function(MonthlySummary) updates) =>
      super.copyWith((message) => updates(message as MonthlySummary))
          as MonthlySummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MonthlySummary create() => MonthlySummary._();
  @$core.override
  MonthlySummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MonthlySummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MonthlySummary>(create);
  static MonthlySummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get yearMonth => $_getSZ(0);
  @$pb.TagNumber(1)
  set yearMonth($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasYearMonth() => $_has(0);
  @$pb.TagNumber(1)
  void clearYearMonth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get totalIncome => $_getN(1);
  @$pb.TagNumber(2)
  set totalIncome($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalIncome() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalIncome() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get totalExpense => $_getN(2);
  @$pb.TagNumber(3)
  set totalExpense($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalExpense() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalExpense() => $_clearField(3);
}

class GetDashboardResponse extends $pb.GeneratedMessage {
  factory GetDashboardResponse({
    $core.double? totalIncome,
    $core.double? totalExpense,
    $core.Iterable<MonthlySummary>? monthly,
    $core.Iterable<$1.Transaction>? recentTransactions,
  }) {
    final result = create();
    if (totalIncome != null) result.totalIncome = totalIncome;
    if (totalExpense != null) result.totalExpense = totalExpense;
    if (monthly != null) result.monthly.addAll(monthly);
    if (recentTransactions != null)
      result.recentTransactions.addAll(recentTransactions);
    return result;
  }

  GetDashboardResponse._();

  factory GetDashboardResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDashboardResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDashboardResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'findiary.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'totalIncome')
    ..aD(2, _omitFieldNames ? '' : 'totalExpense')
    ..pPM<MonthlySummary>(3, _omitFieldNames ? '' : 'monthly',
        subBuilder: MonthlySummary.create)
    ..pPM<$1.Transaction>(4, _omitFieldNames ? '' : 'recentTransactions',
        subBuilder: $1.Transaction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDashboardResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDashboardResponse copyWith(void Function(GetDashboardResponse) updates) =>
      super.copyWith((message) => updates(message as GetDashboardResponse))
          as GetDashboardResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDashboardResponse create() => GetDashboardResponse._();
  @$core.override
  GetDashboardResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDashboardResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDashboardResponse>(create);
  static GetDashboardResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get totalIncome => $_getN(0);
  @$pb.TagNumber(1)
  set totalIncome($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalIncome() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalIncome() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get totalExpense => $_getN(1);
  @$pb.TagNumber(2)
  set totalExpense($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalExpense() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalExpense() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<MonthlySummary> get monthly => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$1.Transaction> get recentTransactions => $_getList(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
