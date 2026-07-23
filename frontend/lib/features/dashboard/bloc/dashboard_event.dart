import 'package:equatable/equatable.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

final class DashboardRequested extends DashboardEvent {
  final String? scopeId;
  final String? scopeType;

  const DashboardRequested({this.scopeId, this.scopeType});

  @override
  List<Object?> get props => [scopeId, scopeType];
}
