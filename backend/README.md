# SE Energy API

FastAPI backend for the SE Energy dashboard.

## Run

```bash
uv sync
uv run fastapi dev app/main.py --host 0.0.0.0 --port 8000
```

- OpenAPI docs: http://localhost:8000/docs
- Health: http://localhost:8000/health

## Structure

| Path | Responsibility |
| --- | --- |
| `app/main.py` | `create_app()` factory, CORS, lifespan, routers |
| `app/core/config.py` | `SE_*` environment settings |
| `app/api/deps.py` | Annotated dependencies (`SettingsDep`, `StoreDep`) |
| `app/api/routes/` | health/meta, sites, metrics |
| `app/schemas.py` | Pydantic request/response models |
| `app/services/site_store.py` | In-memory seeded store |

## Configuration

Copy `.env.example` to `.env`:

| Variable | Default | Notes |
| --- | --- | --- |
| `SE_ENVIRONMENT` | `local` | `local`, `staging`, `production` |
| `SE_DEBUG` | `true` | Enables debug error pages |
| `SE_CORS_ORIGINS` | localhost:5173 | Comma-separated extra origins |
| `SE_CORS_ORIGIN_REGEX` | localhost any port | Dev convenience; tighten in prod |

## Tests

```bash
uv run pytest
uv run ruff check .
uv run ruff format --check .
```

Tests create an isolated app per test through `create_app(Settings(...))`, so
state never leaks between cases.

## Adding persistence

`SiteStore` is deliberately small. To move to a database:

1. Add SQLModel/SQLAlchemy and a session dependency.
2. Reimplement `list/get/create/delete` against the session.
3. Attach the implementation in `create_app`'s lifespan instead of
   `SiteStore.seeded()`.
