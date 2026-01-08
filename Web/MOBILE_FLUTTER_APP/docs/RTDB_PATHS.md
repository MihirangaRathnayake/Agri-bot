# RTDB Paths and Shapes

Firebase RTDB URL from web config: `https://agri-bot-17548-default-rtdb.firebaseio.com`

## Nodes Used by Web App
- `/soil/sensor1_percent` — read; number (0-100). Soil moisture sensor 1 percent.
- `/soil/sensor2_percent` — read; number (0-100). Soil moisture sensor 2 percent.
- `/soil/pump1` — read/write; boolean. Pump 1 toggle for irrigation.
- `/soil/pump2` — read/write; boolean. Pump 2 toggle for irrigation.
- `/tank/level_percent` — read; number (0-100). Water tank level percent.
- `/tank/pump` — read/write; boolean. Tank pump control.
- `/weather/temperature` — read; number (float allowed). Temperature value (displayed with one decimal place).
- `/weather/humidity` — read; number. Humidity percent.
- `/light/state` — read; string. Expected values: `"DARK"` or `"BRIGHT"`.
- `/security/last_motion_time` — read; string (timestamp or descriptive text of last motion event).

## Example JSON Shape
```json
{
  "soil": {
    "sensor1_percent": 55,
    "sensor2_percent": 62,
    "pump1": false,
    "pump2": true
  },
  "tank": {
    "level_percent": 48,
    "pump": false
  },
  "weather": {
    "temperature": 27.4,
    "humidity": 68
  },
  "light": {
    "state": "BRIGHT"
  },
  "security": {
    "last_motion_time": "2025-09-08 14:32:10"
  }
}
```

## Notes
- Writes performed by the web UI: `/soil/pump1`, `/soil/pump2`, and `/tank/pump` (all boolean toggles).
- Other paths seen only in legacy test script (`firebase-test.js`): `/moisture`, `/pump`, `/weather`, `/isDark`, `/security/last_motion_time`. These are not used in the production UI; keep main paths above authoritative.
