// This placeholder keeps the project compiling before running `flutterfire configure`.
// Run: flutterfire configure --project <your-project> --out=lib/firebase_options.dart
// Then remove this placeholder file. Do not commit real keys.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Missing Firebase configuration. Run `flutterfire configure` to generate firebase_options.dart.',
    );
  }
}
