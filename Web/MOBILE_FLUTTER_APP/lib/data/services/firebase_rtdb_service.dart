import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class FirebaseRtdbService {
  FirebaseRtdbService(this._db);

  final FirebaseDatabase _db;

  DatabaseReference _ref(String path) => _db.ref(path);

  Stream<T?> streamValue<T>(String path, T? Function(Object?) parser) {
    return _ref(path).onValue.map((event) => parser(event.snapshot.value));
  }

  Future<T?> readOnce<T>(String path, T? Function(Object?) parser) async {
    final snapshot = await _ref(path).get();
    return parser(snapshot.value);
  }

  Future<void> setValue(String path, Object? value) {
    return _ref(path).set(value);
  }

  Future<void> toggleBool(String path) async {
    final ref = _ref(path);
    final snapshot = await ref.get();
    final current = snapshot.value is bool ? snapshot.value as bool : false;
    await ref.set(!current);
  }
}

bool? parseBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == 'on' || lower == '1') return true;
    if (lower == 'false' || lower == 'off' || lower == '0') return false;
  }
  return null;
}

double? parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    return parsed;
  }
  return null;
}

String? parseString(Object? value) {
  return value?.toString();
}
