# Feature Map (Web → Flutter)

This document captures the current React web app features and maps them to the planned Flutter screens. Firebase Realtime Database config in web: `https://agri-bot-17548-default-rtdb.firebaseio.com`.

## Web Pages
- Dashboard (`/`): main experience composed of sections below.
- Contact (`/contact`): animated form and contact info; no backend calls (simulated submit only).

## Dashboard Sections (React components)
- Hero/Navigation/Footer/Loader/FloatingActions/SystemStatus: UI/UX shell, quick actions (refresh, chatbot toggle), and status badge (no RTDB calls).
- SoilMoisture: reads `/soil/sensor1_percent`, `/soil/sensor2_percent` (numbers 0-100). Shows status chips.
- Irrigation: reads and toggles `/soil/pump1`, `/soil/pump2` (booleans). Shows status log.
- Weather: reads `/weather/temperature` (number, can be decimal), `/weather/humidity` (number).
- LightSensor: reads `/light/state` (string: "DARK" or "BRIGHT").
- Tank: reads `/tank/level_percent` (number 0-100) and reads/writes `/tank/pump` (boolean).
- Camera: displays `http://<ESP32-CAM-IP>/stream` image stream; shows offline placeholder on error.
- Security: reads `/security/last_motion_time` (string timestamp/text).
- About: static description of Agri-Bot team/system (no data calls).
- AgriBotChatbot: client-side knowledge base; currently uses placeholder sensor data (no RTDB calls).

## Mobile Screen Mapping
- Dashboard: summary cards (soil moisture snapshots, tank level, pumps state, quick actions).
- Weather: show live temperature/humidity from `/weather/*`.
- Irrigation: control pump1/pump2 at `/soil/pump1` and `/soil/pump2` with logs and safety states.
- Sensors: soil moisture cards `/soil/sensor{1,2}_percent` and light condition `/light/state`.
- Tank/Water: tank level `/tank/level_percent` and pump toggle `/tank/pump` with low-level alert.
- Security: last motion indicator from `/security/last_motion_time`.
- Camera: ESP32-CAM stream view with retry/offline state.
- Chatbot: same knowledge base UX; sensor-awareness placeholder unless connected to RTDB streams.
- Settings/Diagnostics: theme toggle, Firebase init check, RTDB read test, safe test write path.
- Contact/About: static info from web Contact/About sections; no backend writes.
