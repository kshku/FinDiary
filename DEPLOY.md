# FinDiary Deployment Guide

## Prerequisites

- **Go** 1.26+
- **Flutter** 3.x (stable channel)
- **Docker** + Docker Compose
- **PostgreSQL** 16 (if running without Docker)
- **golang-migrate** CLI (if running migrations manually)

---

## Quick Start (Docker)

```bash
git clone https://github.com/kshku/FinDiary.git
cd FinDiary

# Start PostgreSQL, run migrations, and start backend
docker compose up -d

# The gRPC server is now at localhost:9090
```

Then run the Flutter app (see [Frontend Setup](#frontend-setup) below).

To stop:

```bash
docker compose down          # keep data
docker compose down -v       # wipe data too
```

---

## Manual Setup

### 1. PostgreSQL

```bash
docker run -d --name findiary-db \
  -e POSTGRES_USER=findiary \
  -e POSTGRES_PASSWORD=findiary_dev \
  -e POSTGRES_DB=findiary \
  -p 5432:5432 postgres:16-alpine
```

### 2. Run Migrations

```bash
# Install golang-migrate if you don't have it
# macOS:  brew install golang-migrate
# Linux:  go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

cd backend

migrate -path migrations \
  -database "postgres://findiary:findiary_dev@localhost:5432/findiary?sslmode=disable" \
  up
```

### 3. Start Backend

```bash
cd backend
go run ./cmd/server
```

The server starts on `0.0.0.0:9090` by default.

---

## Frontend Setup

### Build Flags

The Flutter app reads the gRPC server address from compile-time defines:

| Flag | Default | Description |
|------|---------|-------------|
| `GRPC_HOST` | `localhost` | Backend gRPC host |
| `GRPC_PORT` | `9090` | Backend gRPC port |

### Desktop / iOS Simulator

`localhost` works — no flags needed:

```bash
cd frontend
fvm flutter pub get
fvm flutter run
```

### Android Emulator

The Android emulator uses `10.0.2.2` to reach the host machine:

```bash
fvm flutter run --dart-define=GRPC_HOST=10.0.2.2
```

### Physical Device (same Wi-Fi)

Find your machine's local IP (`ip addr` / `ifconfig`) and pass it:

```bash
fvm flutter run --dart-define=GRPC_HOST=192.168.1.x
```

### Web

```bash
fvm flutter run -d chrome --dart-define=GRPC_HOST=localhost
```

> **Note:** gRPC-Web requires a proxy (Envoy, grpc-web-proxy) in front of the gRPC server for browser clients. The Flutter mobile/desktop clients use native gRPC directly.

### Building Release APK

```bash
fvm flutter build apk --dart-define=GRPC_HOST=your-server-ip
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Building iOS

```bash
fvm flutter build ios --dart-define=GRPC_HOST=your-server-ip
```

Requires Xcode and Apple Developer signing for device deployment.

---

## Configuration

### Backend (`backend/config.yaml`)

```yaml
server:
  host: "0.0.0.0"
  port: 9090

database:
  host: "localhost"
  port: 5432
  name: "findiary"
  user: "findiary"
  password: "findiary_dev"    # override with DB_PASSWORD env var

jwt:
  secret: "dev-secret-change-in-production"  # override with JWT_SECRET env var
  access_ttl: 15m
  refresh_ttl: 720h
```

**Environment variable overrides:**

| Variable | Overrides |
|----------|-----------|
| `DB_PASSWORD` | `database.password` |
| `JWT_SECRET` | `jwt.secret` |

---

## Production Deployment

### Backend

1. Set strong values for `DB_PASSWORD` and `JWT_SECRET`
2. Use a managed PostgreSQL (AWS RDS, Supabase, etc.)
3. Frontend must use TLS — add a reverse proxy (Caddy, nginx) in front of the gRPC server

### Android

- Set up release signing in `android/app/build.gradle.kts`
- Build: `fvm flutter build apk --release --dart-define=GRPC_HOST=your-server`

### iOS

- Configure signing in Xcode
- Build: `fvm flutter build ios --release --dart-define=GRPC_HOST=your-server`

### Desktop

- Build for your platform: `fvm flutter build linux` / `macos` / `windows`
- The binary can be distributed directly

---

## Useful Commands

```bash
# Reset database
docker compose down -v && docker compose up -d

# View backend logs
docker compose logs -f backend

# Run Flutter tests
cd frontend && fvm flutter test

# Run Go tests
cd backend && go test ./... -v
```

---

## Architecture

```
Flutter Client  ──gRPC──►  Go Backend  ──SQL──►  PostgreSQL
     │                         │
     └─ Drift (SQLite)         └─ pgx/v5
        offline-first
```

- **Offline-first:** All data is stored locally in SQLite (via Drift). The app works without a network connection.
- **Sync:** When connected, the client pushes local changes and pulls remote changes via the gRPC sync protocol.
- **gRPC-Connect:** Backend uses `connect-go` which speaks standard gRPC (for mobile/desktop) and gRPC-Web (for browsers).
