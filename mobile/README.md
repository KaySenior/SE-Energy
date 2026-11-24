# SE Energy mobile client

Flutter client for the SE Energy dashboard. See the [root README](../README.md)
for the full stack quickstart.

## Run

```bash
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:8000
# or: flutter run -d ios / android / macos
```

Without `--dart-define`, the app targets `http://localhost:8000` (or
`http://10.0.2.2:8000` on the Android emulator).

## Structure

| Path | Contents |
| --- | --- |
| `lib/core/api/` | JSON HTTP client and `ApiException` |
| `lib/core/config/` | Base-URL resolution |
| `lib/core/theme/` | Material 3 light/dark themes |
| `lib/features/dashboard/data/` | Repository interface + API implementation |
| `lib/features/dashboard/models/` | `Site`, `MetricsSummary` |
| `lib/features/dashboard/screens/` | Dashboard screen |
| `lib/features/dashboard/widgets/` | Metric cards, site tiles, error view |

## Tests

```bash
flutter analyze
flutter test
```

Tests inject a fake `DashboardRepository`, so no backend is required.
