# Dashboard Aggregation Design

**Date:** 2026-07-13
**Status:** Draft

## Overview

Add a backend aggregation endpoint for dashboard data (monthly income/expense totals) and update the frontend DashboardBloc to consume it. Chart UI is deferred — this delivers the data layer.

## Backend

### Proto (`proto/findiary/v1/dashboard_service.proto`)

New proto file with a single RPC:

```protobuf
message GetDashboardRequest {
  optional string family_id = 1;
  int32 months = 2;  // default 6
}

message MonthlySummary {
  string year_month = 1;
  double total_income = 2;
  double total_expense = 3;
}

message GetDashboardResponse {
  double total_income = 1;
  double total_expense = 2;
  repeated MonthlySummary monthly = 3;
  repeated Transaction recent_transactions = 4;
}

service DashboardService {
  rpc GetDashboard(GetDashboardRequest) returns (GetDashboardResponse);
}
```

### TransactionRepo addition

New method `GetMonthlyTotals(ctx, userID, familyID, months)` with SQL:

```sql
SELECT TO_CHAR(date, 'YYYY-MM') as year_month,
       SUM(CASE WHEN type='income' THEN amount ELSE 0 END) as total_income,
       SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) as total_expense
FROM transactions
WHERE created_by = $1 AND deleted_at IS NULL AND date >= $2
  AND (family_id IS NULL OR family_id = $3)
GROUP BY year_month ORDER BY year_month DESC
```

### DashboardService (`internal/service/dashboard_service.go`)

- No domain interface (concrete struct like SyncService)
- Depends on `TransactionRepo` and `FamilyRepo`
- `GetDashboard(ctx, userID, familyID, months)` calls `TransactionRepo` for monthly totals and recent transactions
- If `familyID` is provided, checks membership via `FamilyRepo.IsMember` before returning data
- Result struct: `DashboardData` with `TotalIncome`, `TotalExpense`, `MonthlySummaries`, `RecentTransactions`

### DashboardHandler (`internal/api/dashboard_handler.go`)

- Standard connect-go handler
- Extracts userID from context
- Calls service, maps to proto response

### Wiring (`internal/server/server.go`)

- Instantiate `DashboardHandler`, register on mux via `pbv1connect.NewDashboardServiceHandler`

## Frontend

### DashboardGrpcService (`lib/core/grpc/dashboard_service.dart`)

- Wraps the generated `DashboardServiceClient`
- Single `getDashboard({familyId, months})` method

### DashboardBloc update

- Add `MonthlySummary` import to state
- `DashboardLoaded` gains `monthlySummaries` field (default empty)
- Bloc loads local DB data first (offline fallback), then calls server for monthly aggregation
- On server error, continue with empty monthly data

### DI (`lib/core/di/injection.dart`)

- Register `DashboardGrpcService` as lazy singleton

## Testing

- Backend: `dashboard_service_test.go` — 3 tests (aggregation returns data, filters by months, family scope)
- Frontend: `dashboard_grpc_service_test.dart` — mock client, verify request/response mapping

## Files

- Create: `proto/findiary/v1/dashboard_service.proto`
- Generate: run `buf generate` (or equivalent proto gen)
- Create: `backend/internal/service/dashboard_service.go`
- Create: `backend/internal/api/dashboard_handler.go`
- Modify: `backend/internal/repository/transaction_repo.go` — add GetMonthlyTotals
- Modify: `backend/internal/server/server.go` — wire DashboardService
- Create: `frontend/lib/core/grpc/dashboard_service.dart`
- Modify: `frontend/lib/features/dashboard/bloc/dashboard_state.dart` — add monthlySummaries
- Modify: `frontend/lib/features/dashboard/bloc/dashboard_bloc.dart` — load aggregation
- Modify: `frontend/lib/core/di/injection.dart` — register DashboardGrpcService
- Create: `backend/internal/service/dashboard_service_test.go`
- Create: `backend/internal/api/dashboard_handler_test.go` (optional, follows existing pattern)
