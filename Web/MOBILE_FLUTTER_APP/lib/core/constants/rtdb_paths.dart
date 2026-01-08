class RtdbPaths {
  static const soilSensor1 = '/soil/sensor1_percent';
  static const soilSensor2 = '/soil/sensor2_percent';
  static const pump1 = '/soil/pump1';
  static const pump2 = '/soil/pump2';

  static const tankLevel = '/tank/level_percent';
  static const tankPump = '/tank/pump';

  static const temperature = '/weather/temperature';
  static const humidity = '/weather/humidity';

  static const lightState = '/light/state';

  static const lastMotion = '/security/last_motion_time';

  static const diagnosticsRead = lightState;
  static const diagnosticsWrite = '/app/diagnostics/last_check';
}
