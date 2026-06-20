import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const bool kUseEmulator =
    bool.fromEnvironment('USE_EMULATOR', defaultValue: kDebugMode);

class AppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Opções mínimas para bootstrap local sem arquivos nativos.
    // Em produção, substituir por valores reais do projeto.
    return const FirebaseOptions(
      apiKey: 'codequest-local-api-key',
      appId: '1:1234567890:android:codequestlocal',
      messagingSenderId: '1234567890',
      projectId: 'codequest-local',
      storageBucket: 'codequest-local.appspot.com',
    );
  }
}

Future<void> configureFirebase() async {
  if (!kUseEmulator) {
    return;
  }

  final String host = _resolveEmulatorHost();

  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
}

String _resolveEmulatorHost() {
  if (kIsWeb) {
    return 'localhost';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return '10.0.2.2';
  }

  if (Platform.isIOS || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return 'localhost';
  }

  return 'localhost';
}

