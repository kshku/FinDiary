# FinDiary

Personal and family finance tracker. Offline-first, syncs when the server is around.

## Stack

- **Backend:** Go, PostgreSQL, gRPC (connect-go)
- **Frontend:** Flutter, drift (SQLite), flutter_bloc

## Structure

```
FinDiary/
├── backend/         # Go server
├── frontend/        # Flutter app
├── proto/           # Protobuf definitions
└── docs/            # Specs and plans
```

## Getting started

```bash
# Start PostgreSQL
docker run -d --name findiary-db \
  -e POSTGRES_USER=findiary \
  -e POSTGRES_PASSWORD=findiary_dev \
  -e POSTGRES_DB=findiary \
  -p 5432:5432 postgres:16-alpine

# Run migrations
cd backend
go run ./cmd/server  # runs migrations at startup

# Start the app
cd frontend
flutter pub get
flutter run
```

## Commits

Conventional commits. Keep it simple:

```
feat: add transaction sync
fix: handle null category on edit
docs: update setup instructions
```


