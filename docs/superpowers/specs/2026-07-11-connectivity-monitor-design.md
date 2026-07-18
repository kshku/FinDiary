# Connectivity Monitor — Design Spec

**Date:** 2026-07-11  
**Status:** Draft  
**Depends on:** SyncEngine (existing)

## Problem

SyncEngine attempts gRPC calls regardless of network state. When the device is offline, every sync attempt fails with an exception, triggering unnecessary retry backoff cycles. The SyncEngine should be network-aware.

## Design

### ConnectivityNotifier (`core/network/connectivity_notifier.dart`)

A thin wrapper around `connectivity_plus` that exposes network state.

```dart
class ConnectivityNotifier {
  /// Last known online state (defaults to false).
  bool get isOnline;

  /// Stream that emits true/false on network transitions.
  Stream<bool> get onConnectivityChanged;

  /// Must be called to start listening.
  void initialize();

  void dispose();
}
```

- On `initialize()`, checks current connectivity and starts listening for changes
- Maps `connectivity_plus` results: `ConnectivityResult.none` → offline, anything else → online
- Defaults to `isOnline = false` (assume offline until proven otherwise)
- `dispose()` cancels the subscription

### Changes to SyncEngine

- New constructor parameter: `ConnectivityNotifier connectivityNotifier`
- Before gRPC call in `syncNow()`, check `connectivityNotifier.isOnline` — return `SyncResult.failure` immediately if false
- On initialization, subscribe to `connectivityNotifier.onConnectivityChanged` — when transitioning false→true, trigger `syncNow()`
- Keep existing `WidgetsBindingObserver` and debounce logic

### Changes to DI (`injection.dart`)

- Register `ConnectivityNotifier` as lazy singleton
- Pass to `SyncEngine` constructor

### Test Plan

- Mock `connectivity_plus` using `mocktail`
- Test that `syncNow()` skips gRPC call and returns failure when `isOnline == false`
- Test that `syncNow()` proceeds when `isOnline == true`
- Test that offline→online transition triggers `syncNow()`
- Test that `initialize()` works correctly
