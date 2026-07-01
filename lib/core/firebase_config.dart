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
    // A apiKey precisa respeitar o formato AIza... (39 chars): o SDK de Cloud
    // Functions no Android valida o formato antes de chamar, mesmo no emulador
    // (Auth/Firestore não validam). Valor fake só para passar na validação local.
    return const FirebaseOptions(
      apiKey: 'AIzaSyCodequestLocalEmulatorDummyKey000',
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

  try {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  } catch (_) {
    // Em hot restart os emuladores já estão apontados; reconfigurar lança e pode
    // ser ignorado com segurança.
  }
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

