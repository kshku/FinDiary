# Dashboard Aggregation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a backend aggregation endpoint for dashboard monthly income/expense data and update the frontend DashboardBloc to consume it.

**Architecture:** New `DashboardService` proto + handler on the backend with a single `GetDashboard` RPC. A `GetMonthlyTotals` method on `TransactionRepo` does the SQL aggregation. Frontend `DashboardGrpcService` wrapper + `DashboardBloc` update adds monthly summaries to the state.

**Tech Stack:** Go (connect-go), Flutter (bloc), PostgreSQL, protobuf

---

### Task 1: Proto definition + code generation

**Files:**
- Create: `proto/findiary/v1/dashboard_service.proto`
- Generated: Go + Dart protobuf stubs (via `buf generate` or `protoc`)

- [ ] **Step 1: Write the proto file**

```protobuf
syntax = "proto3";

package findiary.v1;

option go_package = "github.com/kshku/findiary/backend/internal/api/findiary/v1";

import "findiary/v1/common.proto";

message GetDashboardRequest {
  optional string family_id = 1;
  int32 months = 2;
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

- [ ] **Step 2: Generate code**

```bash
cd backend && buf generate ../proto
cd frontend && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add proto/ backend/internal/api/findiary/ frontend/lib/generated/
git commit -m "feat(proto): add DashboardService with GetDashboard RPC"
```

---

### Task 2: Backend — repo aggregation method

**Files:**
- Modify: `backend/internal/repository/transaction_repo.go`

- [ ] **Step 1: Write the failing test**

Add to `backend/internal/repository/transaction_repo_test.go`:

```go
func TestGetMonthlyTotals(t *testing.T) {
    // Insert test transactions in different months
    // Verify aggregation returns correct monthly totals
}
```

Run: `cd backend && go test ./internal/repository/ -run TestGetMonthlyTotals -v`
Expected: FAIL (method not defined)

- [ ] **Step 2: Implement `GetMonthlyTotals` on `TransactionRepo`**

Add method to `transaction_repo.go`:

```go
type MonthlyTotal struct {
    YearMonth    string
    TotalIncome  float64
    TotalExpense float64
}

func (r *TransactionRepo) GetMonthlyTotals(ctx context.Context, userID string, familyID *string, months int) ([]MonthlyTotal, error) {
    cutoff := time.Now().AddDate(0, -months, 0).Format("2006-01-02")
    query := `SELECT TO_CHAR(date, 'YYYY-MM') as year_month,
                     COALESCE(SUM(CASE WHEN type='income' THEN amount ELSE 0 END), 0) as total_income,
                     COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END), 0) as total_expense
              FROM transactions
              WHERE created_by = $1 AND deleted_at IS NULL AND date >= $2
                AND (family_id IS NULL OR family_id = $3)
              GROUP BY year_month ORDER BY year_month DESC`
    rows, err := r.pool.Query(ctx, query, userID, cutoff, familyID)
    if err != nil {
        return nil, fmt.Errorf("get monthly totals: %w", err)
    }
    defer rows.Close()
    var totals []MonthlyTotal
    for rows.Next() {
        var mt MonthlyTotal
        if err := rows.Scan(&mt.YearMonth, &mt.TotalIncome, &mt.TotalExpense); err != nil {
            return nil, fmt.Errorf("scan monthly total: %w", err)
        }
        totals = append(totals, mt)
    }
    return totals, rows.Err()
}
```

- [ ] **Step 3: Run test to verify it passes**

Run: `cd backend && go test ./internal/repository/ -run TestGetMonthlyTotals -v`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add backend/internal/repository/transaction_repo.go
git commit -m "feat: add GetMonthlyTotals method to TransactionRepo"
```

---

### Task 3: Backend — DashboardService

**Files:**
- Create: `backend/internal/service/dashboard_service.go`

- [ ] **Step 1: Write the failing test**

Create `backend/internal/service/dashboard_service_test.go`:

```go
func TestDashboardService_GetDashboard(t *testing.T) {
    // Mock TransactionRepo returning monthly totals + recent transactions
    // Verify GetDashboard returns aggregated data
}
```

Run: `cd backend && go test ./internal/service/ -run TestDashboardService -v`
Expected: FAIL

- [ ] **Step 2: Implement DashboardService**

```go
package service

import (
    "context"
    "fmt"
    "github.com/kshku/findiary/backend/internal/domain"
    "github.com/kshku/findiary/backend/internal/repository"
)

type DashboardService struct {
    txRepo     *repository.TransactionRepo
    familyRepo *repository.FamilyRepo
}

func NewDashboardService(txRepo *repository.TransactionRepo, familyRepo *repository.FamilyRepo) *DashboardService {
    return &DashboardService{txRepo: txRepo, familyRepo: familyRepo}
}

type DashboardData struct {
    TotalIncome       float64
    TotalExpense      float64
    Monthly           []repository.MonthlyTotal
    RecentTransactions []*domain.Transaction
}

func (s *DashboardService) GetDashboard(ctx context.Context, userID string, familyID *string, months int) (*DashboardData, error) {
    if months <= 0 || months > 12 {
        months = 6
    }
    if familyID != nil {
        isMember, err := s.familyRepo.IsMember(ctx, *familyID, userID)
        if err != nil {
            return nil, fmt.Errorf("check membership: %w", err)
        }
        if !isMember {
            return nil, fmt.Errorf("%w: not a family member", domain.ErrForbidden)
        }
    }
    totals, err := s.txRepo.GetMonthlyTotals(ctx, userID, familyID, months)
    if err != nil {
        return nil, err
    }
    var totalIncome, totalExpense float64
    for _, m := range totals {
        totalIncome += m.TotalIncome
        totalExpense += m.TotalExpense
    }
    recent, _, err := s.txRepo.List(ctx, domain.TransactionFilter{
        FamilyID:  familyID,
        PageSize:  5,
        PageToken: 0,
    })
    if err != nil {
        return nil, err
    }
    return &DashboardData{
        TotalIncome:       totalIncome,
        TotalExpense:      totalExpense,
        Monthly:           totals,
        RecentTransactions: recent,
    }, nil
}
```

- [ ] **Step 3: Run test to verify it passes**

Run: `cd backend && go test ./internal/service/ -run TestDashboardService -v`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add backend/internal/service/dashboard_service.go backend/internal/service/dashboard_service_test.go
git commit -m "feat: add DashboardService with GetDashboard"
```

---

### Task 4: Backend — DashboardHandler + wiring

**Files:**
- Create: `backend/internal/api/dashboard_handler.go`
- Modify: `backend/internal/server/server.go`

- [ ] **Step 1: Write the handler test**

Create `backend/internal/api/dashboard_handler_test.go`:

```go
func TestDashboardHandler_GetDashboard(t *testing.T) {
    // Create handler with mock service
    // Send connect Request, verify response
}
```

Run: `cd backend && go test ./internal/api/ -run TestDashboardHandler -v`
Expected: FAIL

- [ ] **Step 2: Implement DashboardHandler**

```go
package api

import (
    "context"
    "github.com/bufbuild/connect-go"
    pb "github.com/kshku/findiary/backend/internal/api/findiary/v1"
    "github.com/kshku/findiary/backend/internal/service"
)

type DashboardHandler struct {
    svc *service.DashboardService
}

func NewDashboardHandler(svc *service.DashboardService) *DashboardHandler {
    return &DashboardHandler{svc: svc}
}

func (h *DashboardHandler) GetDashboard(ctx context.Context, req *connect.Request[pb.GetDashboardRequest]) (*connect.Response[pb.GetDashboardResponse], error) {
    userID := UserIDFromContext(ctx)
    months := int(req.Msg.Months)
    data, err := h.svc.GetDashboard(ctx, userID, req.Msg.FamilyId, months)
    if err != nil {
        return nil, mapError(err)
    }
    monthly := make([]*pb.MonthlySummary, len(data.Monthly))
    for i, m := range data.Monthly {
        monthly[i] = &pb.MonthlySummary{
            YearMonth:   m.YearMonth,
            TotalIncome: m.TotalIncome,
            TotalExpense: m.TotalExpense,
        }
    }
    txs := make([]*pb.Transaction, len(data.RecentTransactions))
    for i, tx := range data.RecentTransactions {
        txs[i] = domainTransactionToProto(tx)
    }
    return connect.NewResponse(&pb.GetDashboardResponse{
        TotalIncome:       data.TotalIncome,
        TotalExpense:      data.TotalExpense,
        Monthly:           monthly,
        RecentTransactions: txs,
    }), nil
}
```

- [ ] **Step 3: Wire in server.go**

After the sync handler registration block, add:

```go
dashboardSvc := service.NewDashboardService(txRepo, familyRepo)
dashboardHandler := api.NewDashboardHandler(dashboardSvc)

dashboardPattern, dashboardHTTPHandler := pbv1connect.NewDashboardServiceHandler(
    dashboardHandler,
    connect.WithInterceptors(
        LoggingInterceptor(logger),
        AuthInterceptor(mgr),
    ),
)
mux.Handle(dashboardPattern, dashboardHTTPHandler)
```

Add the import for `pbv1connect` generated package (should already be imported from other handlers).

- [ ] **Step 4: Run backend tests**

Run: `cd backend && go test ./...`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add backend/internal/api/dashboard_handler.go backend/internal/api/dashboard_handler_test.go backend/internal/server/server.go
git commit -m "feat: add DashboardHandler and wire DashboardService in server"
```

---

### Task 5: Frontend — gRPC service wrapper + DI

**Files:**
- Create: `frontend/lib/core/grpc/dashboard_service.dart`
- Modify: `frontend/lib/core/di/injection.dart`

- [ ] **Step 1: Write the failing test**

Create `frontend/test/core/grpc/dashboard_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:findiary/core/grpc/dashboard_service.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pbgrpc.dart' as grpc;
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';

class MockDashboardClient extends Mock implements grpc.DashboardServiceClient {}

void main() {
  late MockDashboardClient mockClient;
  late DashboardGrpcService service;

  setUp(() {
    mockClient = MockDashboardClient();
    service = DashboardGrpcService(mockClient);
  });

  group('DashboardGrpcService', () {
    test('getDashboard returns response', () async {
      final response = GetDashboardResponse(
        totalIncome: 50000,
        totalExpense: 30000,
        monthly: [MonthlySummary(yearMonth: '2026-07', totalIncome: 50000, totalExpense: 30000)],
      );
      when(() => mockClient.getDashboard(any())).thenAnswer((_) async => response);

      final result = await service.getDashboard();
      expect(result.totalIncome, 50000);
      expect(result.totalExpense, 30000);
      expect(result.monthly.length, 1);
    });
  });
}
```

- [ ] **Step 2: Implement DashboardGrpcService**

```dart
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';
import 'package:findiary/generated/findiary/v1/dashboard_service.pbgrpc.dart';

class DashboardGrpcService {
  final DashboardServiceClient _client;

  DashboardGrpcService(this._client);

  Future<GetDashboardResponse> getDashboard({String? familyId, int months = 6}) async {
    final request = GetDashboardRequest(
      familyId: familyId,
      months: months,
    );
    return _client.getDashboard(request);
  }
}
```

- [ ] **Step 3: Register in DI**

In `frontend/lib/core/di/injection.dart`, add:

```dart
import '../grpc/dashboard_service.dart';
// ...after syncService registration:
final dashboardGrpcClient = grpcClient.createDashboardServiceClient();
sl.registerLazySingleton<DashboardGrpcService>(() => DashboardGrpcService(dashboardGrpcClient));
```

Add `createDashboardServiceClient()` to `GrpcClient`:

```dart
import '../../generated/findiary/v1/dashboard_service.pbgrpc.dart' as dashboard_grpc;
// in GrpcClient class:
dashboard_grpc.DashboardServiceClient createDashboardServiceClient() {
  return dashboard_grpc.DashboardServiceClient(_channel);
}
```

- [ ] **Step 4: Run test**

Run: `cd frontend && flutter test test/core/grpc/dashboard_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/grpc/dashboard_service.dart frontend/lib/core/di/injection.dart frontend/lib/core/client/grpc_client.dart frontend/test/core/grpc/dashboard_service_test.dart
git commit -m "feat: add DashboardGrpcService wrapper with DI registration"
```

---

### Task 6: Frontend — DashboardBloc update for monthly aggregation

**Files:**
- Modify: `frontend/lib/features/dashboard/bloc/dashboard_state.dart`
- Modify: `frontend/lib/features/dashboard/bloc/dashboard_bloc.dart`
- Modify: `frontend/lib/features/dashboard/dashboard_page.dart`

- [ ] **Step 1: Write the failing test**

Update `frontend/test/features/dashboard/dashboard_bloc_test.dart`:

```dart
test('loads monthly summaries', () async {
  when(() => mockTransactionDao.sumTransactions(type: any(named: 'type')))
      .thenAnswer((_) async => 0);
  when(() => mockTransactionDao.listTransactions(limit: any(named: 'limit')))
      .thenAnswer((_) async => []);

  final bloc = DashboardBloc(
    transactionDao: mockTransactionDao,
    dashboardGrpcService: mockDashboardGrpcService,
  );

  when(() => mockDashboardGrpcService.getDashboard()).thenAnswer((_) async =>
      GetDashboardResponse(
        totalIncome: 50000,
        totalExpense: 30000,
        monthly: [MonthlySummary(yearMonth: '2026-07', totalIncome: 50000, totalExpense: 30000)],
        recentTransactions: [],
      ));

  bloc.add(const DashboardRequested());
  await expectLater(
    bloc.stream,
    emitsInOrder([isA<DashboardLoading>(), isA<DashboardLoaded>()]),
  );
  final state = bloc.state as DashboardLoaded;
  expect(state.monthlySummaries.length, 1);
});
```

- [ ] **Step 2: Update DashboardState**

Add `MonthlySummary` import and new field:

```dart
import 'package:findiary/generated/findiary/v1/dashboard_service.pb.dart';

final class DashboardLoaded extends DashboardState {
  final double totalIncome;
  final double totalExpense;
  final List<MonthlySummary> monthlySummaries;
  final List<Transaction> recentTransactions;

  const DashboardLoaded({
    required this.totalIncome,
    required this.totalExpense,
    this.monthlySummaries = const [],
    required this.recentTransactions,
  });

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [totalIncome, totalExpense, monthlySummaries, recentTransactions];
}
```

- [ ] **Step 3: Update DashboardBloc**

```dart
import 'package:findiary/core/grpc/dashboard_service.dart';
// Add constructor parameter
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TransactionDao _transactionDao;
  final DashboardGrpcService _dashboardGrpcService;

  DashboardBloc({
    required TransactionDao transactionDao,
    required DashboardGrpcService dashboardGrpcService,
  }) : _transactionDao = transactionDao,
       _dashboardGrpcService = dashboardGrpcService,
       super(const DashboardInitial()) {
    on<DashboardRequested>(_onRequested);
  }

  Future<void> _onRequested(DashboardRequested event, Emitter<DashboardState> emit) async {
    emit(const DashboardLoading());
    try {
      final income = await _transactionDao.sumTransactions(type: 'income');
      final expense = await _transactionDao.sumTransactions(type: 'expense');
      final recent = await _transactionDao.listTransactions(limit: 10);

      List<MonthlySummary> monthly = [];
      try {
        final serverData = await _dashboardGrpcService.getDashboard();
        monthly = serverData.monthly;
      } catch (_) {
        // Offline — use empty monthly data
      }

      emit(DashboardLoaded(
        totalIncome: income,
        totalExpense: expense,
        monthlySummaries: monthly,
        recentTransactions: recent,
      ));
    } catch (_) {
      emit(const DashboardLoaded(
        totalIncome: 0,
        totalExpense: 0,
        recentTransactions: [],
      ));
    }
  }
}
```

- [ ] **Step 4: Update DashboardPage**

Pass `DashboardGrpcService` when creating the Bloc:

```dart
import 'package:findiary/core/grpc/dashboard_service.dart';
// In create:
create: (_) => DashboardBloc(
  transactionDao: sl<TransactionDao>(),
  dashboardGrpcService: sl<DashboardGrpcService>(),
),
```

- [ ] **Step 5: Run Flutter tests**

Run: `cd frontend && flutter test`
Expected: All 29+ tests pass, 0 failures

- [ ] **Step 6: Commit**

```bash
git add frontend/lib/features/dashboard/ frontend/test/features/dashboard/
git commit -m "feat: update DashboardBloc with monthly aggregation from server"
```

---

### Task 7: Run full test suite and open PR

- [ ] **Step 1: Run all backend tests**

```bash
cd backend && go test ./... -count=1
```
Expected: All 30+ tests pass

- [ ] **Step 2: Run Flutter analyze**

```bash
cd frontend && flutter analyze
```
Expected: 0 errors, 0 warnings

- [ ] **Step 3: Push branch and open PR**

```bash
git push -u origin feat/dashboard-aggregation
gh pr create --base develop --head feat/dashboard-aggregation --title "feat: dashboard aggregation endpoint" --body "Adds DashboardService with GetDashboard RPC returning monthly income/expense totals. Frontend DashboardBloc updated to consume aggregation data."
```

Expected: PR created successfully
