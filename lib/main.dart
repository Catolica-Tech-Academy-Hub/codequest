import 'package:codequest/core/firebase_config.dart';
import 'package:codequest/core/router.dart';
import 'package:codequest/core/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: AppFirebaseOptions.currentPlatform,
  );
  await configureFirebase();
  runApp(const ProviderScope(child: CodeQuestApp()));
}

class CodeQuestApp extends ConsumerWidget {
  const CodeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'CodeQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

