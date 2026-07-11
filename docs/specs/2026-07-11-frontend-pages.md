# Frontend Pages — Phase 3c

## Overview

Build the Flutter UI pages that make FinDiary usable. Uses the local-first architecture from Phase 3b (SyncEngine, DAO hooks) — all reads/writes go through Drift DAOs, sync runs in the background.

## Architecture

Bloc-per-feature, direct DAO access. No additional repository layer for MVP.

```
Page → Bloc → DAO (local SQLite via Drift)
           ↘ SyncEngine (hooks) → gRPC (background)
```

Each Bloc:
- Reads data from Drift via DAO queries
- Writes mutations through DAO methods (which trigger PendingChanges hooks)
- Emits states based on query results
- No direct gRPC calls from feature Blocs

## Navigation

Bottom Navigation Bar with 4 tabs:
1. Home (Dashboard)
2. Transactions
3. Categories
4. Settings

Uses `go_router` with `StatefulShellRoute` for preserving tab state.

## Theming

3 built-in themes switchable from Settings, persisted via SharedPreferences:

| Theme | Primary | Surface | Income | Expense |
|-------|---------|---------|--------|---------|
| Clean Modern | Purple #6C63FF | White | Green | Red |
| Dark Finance | Navy #1a1a2e | Dark card | Neon green | Coral |
| Warm Minimal | Coral #FF6B6B | Cream | Green | Red |

A `ThemeCubit` loads the saved theme on startup and provides `ThemeData`.
Settings page shows theme selection with preview swatches.

## Dashboard Page

Route: `/`

`DashboardBloc`:
- Streams: current month income total, expense total, last 10 transactions
- Uses `transactionDao.listTransactions()` with date filters
- Listens to Drift table updates for automatic refresh

Layout (top to bottom):
1. Balance card: total income − total expense, formatted
2. Income/Expense summary: side-by-side cards with amounts
3. Recent transactions: last 10, scrollable list
4. Each item: category icon + colored dot, description, amount (green/red), date

## Transaction List Page

Route: `/transactions`

`TransactionListBloc`:
- Loads transactions ordered by date DESC
- Supports type filter: All / Income / Expense
- Pull-to-refresh calls `syncEngine.syncNow()`
- FAB to create new transaction

Layout:
1. Filter chips: All | Income | Expense
2. Grouped by date (Today, Yesterday, This Week, etc.)
3. Each group: date header, transaction items below
4. Each item: category icon (colored), description, amount with sign
5. Tap item → opens edit form

Empty state: illustration + "No transactions yet" + "Add your first transaction" button.

## Transaction Form (Bottom Sheet)

Opens as modal bottom sheet from Transaction List FAB (or edit tap).

Fields:
1. **Type toggle**: Income / Expense (Material segmented button)
2. **Amount**: numeric text field, currency prefix ₹, formatted with commas
3. **Category**: horizontal scrollable grid of icons + names, filtered by selected type
4. **Date**: tappable showing formatted date, opens date picker (defaults to today)
5. **Description**: optional text field

Save: calls `transactionDao.upsertTransaction()` → triggers PendingChanges hook → sync engine runs.

## Categories Page

Route: `/categories`

`CategoryBloc`:
- Reads categories from `categoryDao.listCategories()`
- Groups by type (Income / Expense)
- Read-only for MVP (no create/edit/delete)

Layout:
1. Two sections: Income Categories, Expense Categories
2. Each category: icon + color swatch + name
3. Categories are from the local Drift DB (seeded defaults + server-synced)

## Settings Page

Route: `/settings`

`SettingsBloc`:
- Reads user info from AuthService
- Reads saved theme preference
- Offers logout action

Layout:
1. **Profile**: display name, email
2. **Theme**: horizontal selector with 3 theme preview tiles
3. **Sync status**: last synced time, pending changes count (reads from SyncMetaDao + PendingChanges)
4. **Logout**: button, clears tokens, navigates to login

## File Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_theme.dart        # ThemeData factory + ThemeCubit
│       └── themes/
│           ├── clean_modern.dart
│           ├── dark_finance.dart
│           └── warm_minimal.dart
├── features/
│   ├── dashboard/
│   │   ├── dashboard_page.dart
│   │   └── bloc/
│   │       ├── dashboard_bloc.dart
│   │       ├── dashboard_event.dart
│   │       └── dashboard_state.dart
│   ├── transactions/
│   │   ├── transaction_list_page.dart
│   │   ├── transaction_form_sheet.dart
│   │   ├── widgets/
│   │   │   ├── transaction_tile.dart
│   │   │   └── filter_bar.dart
│   │   └── bloc/
│   │       ├── transaction_list_bloc.dart
│   │       ├── transaction_list_event.dart
│   │       └── transaction_list_state.dart
│   ├── categories/
│   │   ├── categories_page.dart
│   │   ├── widgets/
│   │   │   └── category_tile.dart
│   │   └── bloc/
│   │       ├── category_bloc.dart
│   │       ├── category_event.dart
│   │       └── category_state.dart
│   └── settings/
│       ├── settings_page.dart
│       └── bloc/
│           ├── settings_bloc.dart
│           ├── settings_event.dart
│           └── settings_state.dart
└── app.dart                     # Add ThemeCubit, go_router
```

## DI Changes

Register in `injection.dart`:
- `SharedPreferences` (singleton)
- `ThemeCubit` (singleton)
- All new Blocs
- `go_router` instance

## Testing

Each Bloc gets unit tests with mocked DAOs. Widget tests for critical pages (dashboard, transaction form).

## Out of Scope

- Family management pages (Phase 3d/3e)
- Charts and graphs (Phase 3e)
- Conflict resolution UI (Phase 3d)
- Pull-to-refresh for dashboard (Phase 3e)
- Category create/edit/delete (Phase 3d)
- System category seeding on first launch (deferred)
