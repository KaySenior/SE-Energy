# energy2

a repository for group members to contribute to their end of sem project

## SE Energy starter

Starter monorepo for an energy fleet dashboard: a **Flutter** client and a
**FastAPI** backend.

```
SE Energy 2/
├── backend/           FastAPI app (Python 3.11+, uv)
│   ├── app/
│   │   ├── api/routes/    health, sites, metrics
│   │   ├── core/          settings
│   │   ├── services/      in-memory site store
│   │   ├── main.py        app factory
│   │   └── schemas.py     Pydantic models
│   ├── tests/
│   └── pyproject.toml
├── mobile/            Flutter app (Material 3)
│   ├── lib/
│   │   ├── core/          API client, config, theme, formatters
│   │   ├── features/dashboard/
│   │   └── main.dart
│   └── test/
├── docker-compose.yml
└── Makefile
```

## Prerequisites

- Flutter 3.27+ (developed against 3.44) with the platforms you need
- Python 3.11+ and [uv](https://docs.astral.sh/uv/)
- Optional: Docker for the containerized API

## Quickstart

```bash
make setup      # uv sync + flutter pub get
```

Run the API (terminal 1):

```bash
make api        # http://localhost:8000 — docs at /docs
```

Run the app (terminal 2):

```bash
make web        # Chrome on http://localhost:5173
# or: make ios / make android / make macos
```

The dashboard loads three seeded sites from the API and shows fleet metrics,
status chips, pull-to-refresh, and a retry screen when the backend is offline.

## How the client reaches the API

| Run target | Default base URL |
| --- | --- |
| Web / iOS simulator / macOS | `http://localhost:8000` |
| Android emulator | `http://10.0.2.2:8000` |

Override it for a physical device or deployed backend:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
```

CORS allows `localhost`/`127.0.0.1` on any port in development. Add production
origins through `SE_CORS_ORIGINS` (comma-separated).

## API

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/` | Service index |
| `GET` | `/health` | Liveness probe |
| `GET` | `/api/v1/sites` | List sites |
| `POST` | `/api/v1/sites` | Register a site |
| `GET` | `/api/v1/sites/{id}` | Fetch one site |
| `DELETE` | `/api/v1/sites/{id}` | Delete a site |
| `GET` | `/api/v1/metrics/summary` | Fleet totals |

Example:

```bash
curl -s http://localhost:8000/api/v1/sites
curl -s -X POST http://localhost:8000/api/v1/sites \
  -H 'Content-Type: application/json' \
  -d '{"name":"Cape Coast Array","location":"Cape Coast, GH","capacity_kw":90,"status":"online","today_kwh":0}'
```

Configuration lives in `backend/.env` (copy `backend/.env.example`). All keys
are prefixed with `SE_`, e.g. `SE_DEBUG=false`.

## Tests and linting

```bash
make test       # pytest + flutter test
make lint       # ruff check/format-check + flutter analyze
make format     # auto-format both
```

## Docker

```bash
make docker     # API only, http://localhost:8000
```

## Notes

- The API stores sites in memory; data resets on restart. Replace
  `app/services/site_store.py` with a database repository when you need
  persistence — routes only depend on `list/get/create/delete`.
- Cleartext HTTP is enabled only for local development (Android debug manifest,
  iOS `NSAllowsLocalNetworking`). Use HTTPS in deployed environments.
- `mobile/` is a normal Flutter project, so `flutter create` can add more
  platforms later if needed.
