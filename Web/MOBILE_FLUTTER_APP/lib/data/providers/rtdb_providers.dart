import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/rtdb_paths.dart';
import '../repositories/rtdb_repository.dart';

final soilMoistureProvider =
    StreamProvider.family<double?, int>((ref, sensorIndex) {
  final repo = ref.watch(rtdbRepositoryProvider);
  final path = sensorIndex == 1 ? RtdbPaths.soilSensor1 : RtdbPaths.soilSensor2;
  return repo.numberStream(path);
});

final pumpStatusProvider = StreamProvider.family<bool?, int>((ref, pumpIndex) {
  final repo = ref.watch(rtdbRepositoryProvider);
  final path = pumpIndex == 1 ? RtdbPaths.pump1 : RtdbPaths.pump2;
  return repo.boolStream(path);
});

final tankLevelProvider = StreamProvider<double?>((ref) {
  final repo = ref.watch(rtdbRepositoryProvider);
  return repo.numberStream(RtdbPaths.tankLevel);
});

final tankPumpProvider = StreamProvider<bool?>((ref) {
  final repo = ref.watch(rtdbRepositoryProvider);
  return repo.boolStream(RtdbPaths.tankPump);
});

final temperatureProvider = StreamProvider<double?>((ref) {
  final repo = ref.watch(rtdbRepositoryProvider);
  return repo.numberStream(RtdbPaths.temperature);
});

final humidityProvider = StreamProvider<double?>((ref) {
  final repo = ref.watch(rtdbRepositoryProvider);
  return repo.numberStream(RtdbPaths.humidity);
});

final lightStateProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(rtdbRepositoryProvider);
  return repo.stringStream(RtdbPaths.lightState);
});

final lastMotionProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(rtdbRepositoryProvider);
  return repo.stringStream(RtdbPaths.lastMotion);
});
