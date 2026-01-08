import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/firebase_providers.dart';
import '../services/firebase_rtdb_service.dart';

class RtdbRepository {
  RtdbRepository(this._service);

  final FirebaseRtdbService _service;

  Stream<double?> numberStream(String path) =>
      _service.streamValue(path, parseDouble);

  Stream<bool?> boolStream(String path) =>
      _service.streamValue(path, parseBool);

  Stream<String?> stringStream(String path) =>
      _service.streamValue(path, parseString);

  Future<double?> readNumber(String path) =>
      _service.readOnce(path, parseDouble);

  Future<bool?> readBool(String path) => _service.readOnce(path, parseBool);

  Future<String?> readString(String path) =>
      _service.readOnce(path, parseString);

  Future<void> toggleBool(String path) => _service.toggleBool(path);

  Future<void> writeValue(String path, Object? value) =>
      _service.setValue(path, value);
}

final rtdbRepositoryProvider = Provider<RtdbRepository>((ref) {
  final db = ref.watch(firebaseDatabaseProvider);
  return RtdbRepository(FirebaseRtdbService(db));
});
