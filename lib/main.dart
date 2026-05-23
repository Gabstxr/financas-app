import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'injection/injection_container.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('=== FLUTTER ERROR ===');
      debugPrint(details.exception.toString());
      debugPrint(details.stack.toString());
    };

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await initDependencies();
    runApp(const App());
  }, (error, stack) {
    debugPrint('=== UNCAUGHT ERROR ===');
    debugPrint(error.toString());
    debugPrint(stack.toString());
  });
}
