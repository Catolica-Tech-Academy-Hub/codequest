import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:codequest/features/fill_in_the_blanks/FE_01_tela_exercicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Se o Firebase não estiver configurado na sua máquina local ainda,
  // você pode comentar essas linhas temporariamente para testar o visual da sua tela:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: MaterialApp(
        home: FillInTheBlanksPage(), // Abre direto a sua tela nova!
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}