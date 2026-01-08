# Agri-Bot Mobile (Flutter)

Flutter + Riverpod + Firebase Realtime Database app that mirrors the React web features. All RTDB paths and shapes are documented in `docs/RTDB_PATHS.md` and `docs/FEATURE_MAP.md`.

## Setup
1) Prereqs: Flutter 3.35+, Dart 3.9+, Firebase CLI with flutterfire.
2) From `MOBILE_FLUTTER_APP`, fetch packages: `flutter pub get`.
3) Configure Firebase (no secrets committed):
   - `flutterfire configure --project agri-bot-17548 --out=lib/firebase_options.dart`
   - Select Android+iOS. This replaces the placeholder `lib/firebase_options.dart`.
4) Run: `flutter run` (choose a mobile simulator/device).

## Features
- Dashboard: live weather, soil moisture, pumps, tank status, light and security summaries, quick actions, chatbot entry.
- Weather: temperature and humidity streams from `/weather/temperature` and `/weather/humidity`.
- Irrigation: control `/soil/pump1` and `/soil/pump2` with local log; soil moisture references.
- Sensors: soil moisture cards (`/soil/sensor1_percent`, `/soil/sensor2_percent`), light state (`/light/state`), camera placeholder (`http://<ESP32-CAM-IP>/stream`).
- Tank/Water: tank level and pump control (`/tank/level_percent`, `/tank/pump`).
- Security: last motion time from `/security/last_motion_time`.
- Chatbot: on-device helper with RTDB-aware hints.
- Settings/Diagnostics: theme toggle, RTDB read/write check (reads `/light/state`, writes `/app/diagnostics/last_check`).

## Data Reference
- RTDB URL: `https://agri-bot-17548-default-rtdb.firebaseio.com`
- Paths/types: see `docs/RTDB_PATHS.md` for full list and example JSON.
- All streams are read-only except toggles on `/soil/pump1`, `/soil/pump2`, and `/tank/pump`; diagnostics writes to `/app/diagnostics/last_check`.

## Sample Data (for quick testing)
Use Firebase console or REST (replace `<auth>` with a token if needed):
```bash
curl -X PATCH https://agri-bot-17548-default-rtdb.firebaseio.com/.json \
  -H "Content-Type: application/json" \
  -d '{
    "soil": {"sensor1_percent": 55, "sensor2_percent": 62, "pump1": false, "pump2": true},
    "tank": {"level_percent": 48, "pump": false},
    "weather": {"temperature": 27.4, "humidity": 68},
    "light": {"state": "BRIGHT"},
    "security": {"last_motion_time": "2025-09-08 14:32:10"}
  }'
```

## Architecture
```
lib/
  app/        (router, shell, theme, app wrapper)
  core/       (constants, utils)
  data/       (services, repositories, RTDB providers)
  features/   (dashboard, weather, irrigation, sensors, security, chatbot, settings)
  shared/     (widgets and skeleton loaders)
```

## Notes
- `lib/firebase_options.dart` is a placeholder; run flutterfire configure before building.
- Bottom navigation: Dashboard, Weather, Irrigation, Sensors, Security, More.
- Animations: `flutter_animate` for fades/shimmers; light/dark Material 3 themes.
