# FinDiary: Personal & Family Finance Application — Design Specification

**Version:** 1.0  
**Date:** 2026-07-02  
**Status:** Draft

---

## 1. Overview

FinDiary is a production-quality, offline-first finance application for individuals and families. It replaces traditional handwritten income/expenditure diaries with a modern digital system while maintaining simplicity of recording daily transactions.

**Key usage models:**
- A user can use FinDiary as a **personal finance tracker** without creating or joining any family
- A user can additionally **create or join a family** (group) to share financial records with other members
- Family participation is **entirely optional**; all core features work for solo users
- The underlying design treats "family" as a generic **group** concept, extensible to other group types in the future

The system consists of a **Go backend server** and **Flutter cross-platform clients**. Clients function fully offline and synchronize automatically when the server becomes available.

### 1.1 Design Goals

- **Offline-first**: Every client works completely without server connectivity
- **Reliable sync**: Automatic background synchronization with last-write-wins conflict resolution
- **Family sharing**: Groups of users can share financial records with extensible permissions
- **Production quality**: Clean architecture, separation of concerns, testability, security
- **Public-deployable**: Architecture supports cloud deployment for public use

---

## 2. Domain Model

### 2.1 Entities

```
User
├── id:            UUID v4
├── email:         string (unique, indexed)
├── password_hash: string (bcrypt)
├── display_name:  string
├── created_at:    timestamptz
└── updated_at:    timestamptz

Family
├── id:            UUID v4
├── name:          string
├── owner_id:      UUID → User (not nullable)
├── created_at:    timestamptz
└── updated_at:    timestamptz

FamilyMember
├── family_id:     UUID → Family (PK part 1)
├── user_id:       UUID → User (PK part 2)
├── role:          enum(owner, admin, member)
├── joined_at:     timestamptz
└── invited_by:    UUID → User

Invitation
├── id:            UUID v4
├── family_id:     UUID → Family
├── email:         string (invited user's email)
├── code:          string (unique invite code)
├── status:        enum(pending, accepted, expired, revoked)
├── created_by:    UUID → User
├── created_at:    timestamptz
└── expires_at:    timestamptz

Transaction
├── id:            UUID v4
├── family_id:     UUID → Family (nullable; null = personal transaction)
├── created_by:    UUID → User
├── type:          enum(income, expense)
├── amount:        decimal(18,2)
├── currency:      string (default: INR)
├── category_id:   UUID → Category
├── description:   text (optional)
├── date:          date (transaction date)
├── created_at:    timestamptz
├── updated_at:    timestamptz
└── deleted_at:    timestamptz (soft delete — nullable, indexed for sync)

Category
├── id:            UUID v4
├── scope:         enum(system, personal, family)  — determines visibility
├── family_id:     UUID → Family (nullable; set when scope=family)
├── created_by:    UUID → User (nullable; set when scope=personal)
├── name:          string
├── type:          enum(income, expense)
├── icon:          string (optional, for UI rendering)
├── color:         string (optional, hex color for UI)
├── created_at:    timestamptz
└── updated_at:    timestamptz

ChangeLog
├── id:                bigserial (monotonic, sequential — sync checkpoint)
├── family_id:         UUID → Family (nullable; null = personal scope)
├── changed_by:        UUID → User
├── entity_type:       string (e.g. "transaction", "category")
├── entity_id:         UUID
├── action:            enum(create, update, delete)
├── snapshot:          jsonb (full state of entity after change)
├── changed_fields:    text[] (field names that were modified)
├── server_timestamp:  timestamptz (when server recorded it)
└── client_timestamp:  timestamptz (original timestamp from client device)
```

### 2.2 Key Design Decisions

- **UUID v4** for all primary keys — generated client-side so records can be created offline without server round-trip
- **Soft delete** on transactions — enables sync propagation of deletes
- **ChangeLog as bigserial** (not UUID) — clients track sync progress via a simple monotonic integer checkpoint
- **ChangeLog snapshot is full JSONB** — client receives complete entity state in one record; no need for separate fetch
- **ChangeLog doubles as audit trail** — every mutation is preserved immutably
- **System categories** are family-scoped with `is_system=true`; families can customize without affecting other families

### 2.3 Default Categories (Seeded)

**Income:** Salary, Freelance, Business, Investment, Gift, Refund, Other Income  
**Expense:** Food & Dining, Transport, Utilities, Rent, Shopping, Healthcare, Entertainment, Education, Insurance, Subscription, Other Expense

---

## 3. Sync Protocol

### 3.1 Philosophy

The server is the authoritative source of truth. Clients maintain local copies of all data they have access to. Sync is **pull-based** — the client initiates it. This matches the offline-first requirement.

### 3.2 Protocol Flow

Sync operates per **scope** — either a specific family or the user's personal scope. The client iterates over all scopes (personal + each family) and syncs each independently.

```
Client                              Server
  │                                   │
  │  ── SyncRequest ──────────────►   │
  │  {                                │
  │    scope_id: string,              │  // "" for personal, UUID for family
  │    scope_type: string,            │  // "personal" | "family"
  │    last_checkpoint: int64,        │
  │    local_changes: [ChangeEntry]   │
  │  }                                │
  │                                   │── Validate auth & permissions
  │                                   │── Apply local changes to main tables
  │                                   │── Append to ChangeLog
  │                                   │── Query ChangeLog > client checkpoint
  │                                   │── Resolve LWW conflicts
  │  ◄── SyncResponse ─────────────   │
  │  {                                │
  │    new_checkpoint: int64,         │
  │    remote_changes: [ChangeEntry], │
  │    conflicts: [ConflictInfo]      │
  │  }                                │
  │                                   │
  │── Apply remote changes locally    │
  │── Update local checkpoint         │
```

### 3.3 SyncRequest

```protobuf
message SyncRequest {
  string scope_id = 1;       // "" for personal, UUID for family
  string scope_type = 2;     // "personal" | "family"
  int64 last_checkpoint = 3;
  repeated ChangeEntry local_changes = 4;
}

message ChangeEntry {
  string entity_type = 1;
  string entity_id = 2;
  string action = 3;       // "create" | "update" | "delete"
  bytes snapshot = 4;      // serialized entity protobuf
  google.protobuf.Timestamp client_timestamp = 5;
  repeated string changed_fields = 6;
}
```

### 3.4 Conflict Resolution (Last-Write-Wins)

- **Field-level**: Each field is resolved independently based on `updated_at` timestamps
- **Tiebreaker**: If timestamps are equal (within a configurable tolerance window), the server timestamp wins
- **Losing changes are preserved**: Even when LWW discards a change, it remains in the ChangeLog for audit purposes
- **ConflictInfo**: Returned to client so it can surface notification if desired, but auto-resolved

### 3.5 Client Sync Engine Behavior

- **Auto-sync**: Triggers when app comes to foreground and periodically (configurable interval, default 5 minutes)
- **Manual sync**: User can trigger sync from settings or pull-to-refresh
- **Auto-sync toggle**: User can disable auto-sync in settings
- **Per-scope sync**: Client syncs personal scope + each family the user belongs to, independently
- **Queue**: Pending local changes are stored in a local queue; synced in order when server available
- **Retry**: Exponential backoff on sync failure (30s, 1m, 2m, 4m, max 15m)

### 3.6 Sync Guarantees

- **At-least-once delivery**: Server may receive the same change multiple times (idempotent via entity_id + client_timestamp)
- **Ordering preserved within entity**: Changes to the same entity are applied in chronological order
- **No ordering guarantees across entities**: Cross-entity ordering is not required

---

## 4. Backend Architecture (Go)

### 4.1 Directory Layout

```
backend/
├── cmd/
│   └── server/
│       └── main.go              # Entrypoint: config, DI, start gRPC server
├── internal/
│   ├── domain/                  # Core domain types, interfaces, errors
│   │   ├── user.go
│   │   ├── family.go
│   │   ├── transaction.go
│   │   ├── category.go
│   │   └── changelog.go
│   ├── server/                  # gRPC server setup, interceptors
│   │   ├── server.go
│   │   ├── interceptor.go       # Auth, logging, recovery interceptors
│   │   └── options.go
│   ├── service/                 # Business logic (use cases)
│   │   ├── auth_service.go
│   │   ├── family_service.go
│   │   ├── transaction_service.go
│   │   ├── category_service.go
│   │   └── sync_service.go
│   ├── repository/              # Data access layer (PostgreSQL with pgx)
│   │   ├── user_repo.go
│   │   ├── family_repo.go
│   │   ├── transaction_repo.go
│   │   ├── category_repo.go
│   │   └── changelog_repo.go
│   ├── api/                     # gRPC handler implementations (thin layer)
│   │   ├── auth_handler.go
│   │   ├── family_handler.go
│   │   ├── transaction_handler.go
│   │   ├── category_handler.go
│   │   └── sync_handler.go
│   └── config/
│       ├── config.go
│       └── config.yaml
├── migrations/                  # SQL migrations (golang-migrate)
│   ├── 000001_create_users.up.sql
│   ├── 000001_create_users.down.sql
│   └── ...
├── pkg/
│   ├── jwt/
│   │   └── jwt.go               # Token creation, validation, refresh
│   ├── password/
│   │   └── password.go          # bcrypt hashing & verification
│   └── validator/
│       └── validator.go         # Input validation helpers
├── go.mod
├── go.sum
└── Dockerfile
```

### 4.2 Architectural Layers

| Layer | Responsibility | Depends On |
|-------|---------------|------------|
| `api/` | gRPC handlers: parse requests, call services, format responses | `service/`, generated protobuf |
| `service/` | Business logic, validation, authorization, orchestration | `domain/`, `repository/` |
| `repository/` | Data access: SQL queries, PostgreSQL via `pgx` | `domain/` |
| `domain/` | Pure types, interfaces, domain errors | Nothing |

### 4.3 Key Technical Choices

- **gRPC** with `connect-go` (simpler than `grpc-go`, built on net/http, supports gRPC and gRPC-Web)
- **PostgreSQL driver**: `pgx/v5`
- **Migrations**: `golang-migrate/migrate`
- **Auth**: JWT with access (15min) + refresh (7 day) tokens; bcrypt for passwords
- **Config**: YAML file with env var overrides
- **Logging**: `slog` (Go 1.21+ standard library)
- **Testing**: Standard `testing` package, `testify` for assertions, `testcontainers-go` for integration tests

### 4.4 Configuration

```yaml
server:
  host: "0.0.0.0"
  port: 9090

database:
  host: "localhost"
  port: 5432
  name: "findiary"
  user: "findiary"
  password: "${DB_PASSWORD}"

jwt:
  secret: "${JWT_SECRET}"
  access_ttl: "15m"
  refresh_ttl: "720h"  # 30 days
```

### 4.5 Authentication Flow

```
Register:
  Client → Server: Register(email, password, display_name)
  Server: hash password (bcrypt), create user
  Server: generate access + refresh tokens
  Server → Client: { access_token, refresh_token, user }

Login:
  Client → Server: Login(email, password)
  Server: verify bcrypt hash
  Server: generate access + refresh tokens
  Server → Client: { access_token, refresh_token, user }

Refresh:
  Client → Server: Refresh(refresh_token)
  Server: validate refresh token, issue new access + refresh tokens
  Server → Client: { access_token, refresh_token }

All subsequent gRPC calls: attach access_token in metadata
Interceptor: validate token, inject user context into request context
```

---

## 5. Frontend Architecture (Flutter)

### 5.1 Directory Layout

```
frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart                       # MaterialApp, router setup
│   ├── core/
│   │   ├── client/
│   │   │   ├── grpc_client.dart       # gRPC channel + stub initialization
│   │   │   └── auth_interceptor.dart  # Attaches JWT to requests
│   │   ├── database/
│   │   │   ├── database.dart          # Drift database definition
│   │   │   ├── tables.dart            # Table definitions
│   │   │   └── daos/                  # Data access objects
│   │   │       ├── transaction_dao.dart
│   │   │       ├── category_dao.dart
│   │   │       └── sync_meta_dao.dart
│   │   ├── sync/
│   │   │   ├── sync_manager.dart      # Orchestrates sync lifecycle
│   │   │   ├── sync_queue.dart        # Pending changes queue (Drift-backed)
│   │   │   └── conflict_resolver.dart # Applies LWW merge logic
│   │   ├── auth/
│   │   │   ├── auth_service.dart      # Login/register/refresh logic
│   │   │   └── token_storage.dart     # flutter_secure_storage
│   │   ├── network/
│   │   │   └── connectivity.dart      # Monitors server reachability
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   └── bloc/
│   │   │       ├── auth_bloc.dart
│   │   │       ├── auth_event.dart
│   │   │       └── auth_state.dart
│   │   ├── home/
│   │   │   ├── dashboard_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── balance_card.dart
│   │   │   │   ├── monthly_chart.dart
│   │   │   │   ├── category_pie_chart.dart
│   │   │   │   └── recent_transactions.dart
│   │   │   └── bloc/
│   │   ├── transactions/
│   │   │   ├── transaction_list_page.dart
│   │   │   ├── transaction_form_page.dart
│   │   │   ├── widgets/
│   │   │   │   ├── transaction_tile.dart
│   │   │   │   ├── filter_bar.dart
│   │   │   │   └── search_bar.dart
│   │   │   └── bloc/
│   │   ├── families/
│   │   │   ├── family_page.dart
│   │   │   ├── invite_page.dart
│   │   │   ├── invitations_page.dart
│   │   │   └── bloc/
│   │   └── settings/
│   │       ├── settings_page.dart
│   │       ├── sync_settings.dart
│   │       └── bloc/
│   └── generated/                    # Generated protobuf Dart code
├── test/
│   ├── unit/
│   └── widget/
├── pubspec.yaml
└── ...
```

### 5.2 Key Libraries

| Purpose | Library |
|---------|---------|
| State management | `flutter_bloc` |
| Local database | `drift` (SQLite ORM) |
| gRPC | `grpc` + `protoc_plugin` |
| Charts | `fl_chart` |
| Secure storage | `flutter_secure_storage` |
| Connectivity | `connectivity_plus` |
| Routing | `go_router` |
| DI | `get_it` + `injectable` |

### 5.3 Client Data Flow

```
User Action → Bloc Event → Bloc handles locally:
  1. Update local Drift database immediately (optimistic)
  2. Enqueue change to sync queue (Drift-backed)
  3. Emit new state → UI rebuilds

SyncManager runs:
  1. Check connectivity (on connectivity change or timer)
  2. If server reachable: dequeue pending changes
  3. Call SyncService.Sync() with local changes + last checkpoint
  4. Receive remote changes, apply to local DB (LWW)
  5. Update last checkpoint
  6. Remove synced entries from queue
```

---

## 6. Personal vs Family Mode

### 6.1 Solo (Personal) Mode

When a user registers, they start in **personal mode**:
- Transactions have `family_id = null` (personal scope)
- Categories can be system defaults or personal custom categories (`scope = personal`)
- Sync operates on the personal scope
- No family management UI is needed

The user can continue indefinitely in personal mode with full functionality.

### 6.2 Family Mode

When a user creates or joins a family, they gain an additional **family scope**:
- Transactions can be created in either personal or family scope
- Switching between scopes happens via a family selector in the UI
- Family-scoped data is visible to other family members per permissions

### 6.3 Creating a Family

```
User A → CreateFamily(name: "My Family")
  → Server creates Family with User A as owner
  → Server adds FamilyMember(owner)
  → Client syncs → new family appears

User A → InviteMember(family_id, email: "b@example.com")
  → Server creates Invitation(pending) with unique code
  → (Future: send email; MVP: user B sees invitation on next sync)

User B → on next sync, GetInvitations shows pending invite
User B → AcceptInvitation(code)
  → Server creates FamilyMember(member)
  → User B now has access to family transactions
```

### 6.2 Permissions Model (MVP)

| Role | View All | Create | Edit Any | Edit Own | Delete | Invite | Remove Members |
|------|----------|--------|----------|----------|--------|--------|----------------|
| Owner | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Admin | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| Member | ✓ | ✓ | — | ✓ | — | — | — |

The permission model is stored in extensible form (role enum stored per FamilyMember) so future settings can override these defaults.

---

## 7. Testing Strategy

### 7.1 Backend (Go)

- **Unit tests**: Service layer with mocked repositories (using interfaces)
- **Repository tests**: Integration tests with test PostgreSQL (testcontainers-go)
- **API tests**: gRPC handler tests with in-memory server
- **Sync tests**: End-to-end sync scenarios (multiple clients, offline periods, conflicts)

### 7.2 Frontend (Flutter)

- **Unit tests**: Bloc tests with mocked database + gRPC
- **Widget tests**: UI component tests
- **Integration tests**: Full flow tests (rare; focus on critical paths)
- **Sync engine tests**: Test sync queue, conflict resolution, offline queuing

---

## 8. Future Extensibility

The design explicitly supports these future enhancements:

| Feature | How It's Supported |
|---------|-------------------|
| Reports & charts | Data model supports aggregation; frontend has charting infrastructure |
| Budgeting | Add `Budget` entity (family_id, category_id, amount, period); cross-reference with Transaction |
| Recurring transactions | Add `RecurringRule` entity (schedule, template); service generates transactions |
| Attachments | Add `Attachment` entity (transaction_id, file_key, metadata); file storage separate |
| Notifications | Add notification preference table; push via FCM |
| Data export | Service layer can stream all user data |
| Audit logs | Already built in via ChangeLog |
| Multiple devices per user | Auth supports multiple refresh tokens per user |
| Custom family settings | Settings table (family_id, key, value) referenced by permission checks |
| Enhanced sync strategies | ChangeLog format is extensible; can add vector clocks or CRDTs |

---

## 9. Deployment Model

### 9.1 Development

```bash
# Backend
docker compose up -d postgres   # Start PostgreSQL
cd backend
go run ./cmd/server

# Frontend
cd frontend
flutter run
```

### 9.2 Production (Future)

- **Server**: Docker container deployed via docker-compose or Kubernetes
- **Database**: Managed PostgreSQL (AWS RDS, Supabase, etc.)
- **Reverse proxy**: Caddy or nginx for TLS termination (gRPC needs TLS)
- **Backups**: pg_dump cron job; ChangeLog provides point-in-time recovery

---

## 10. Assumptions & Constraints

- **Single timezone**: MVP assumes all family members are in the same timezone (same household)
- **Single currency**: MVP assumes a single currency per family (default INR)
- **No real-time sync**: Sync is poll-based, not push-based (server is not always online)
- **No file storage**: Attachments deferred to future iteration
- **No email service**: Invitations visible in-app only (email integration deferred)

---

## 11. Open Questions (Future)

1. Should categories be user-level or family-level? (Current: family-level)
2. How to handle multi-currency? (Deferred)
3. Should transactions support splitting across categories? (Deferred)
4. Should we support tags/labels in addition to categories? (Deferred)
