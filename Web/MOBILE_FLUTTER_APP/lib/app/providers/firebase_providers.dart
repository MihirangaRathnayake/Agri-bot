import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

final firebaseInitProvider = FutureProvider<void>((ref) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable local cache for smoother UX.
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  } catch (e, st) {
    // Surface initialization errors to the UI (likely missing flutterfire config).
    Error.throwWithStackTrace(e, st);
  }
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});
