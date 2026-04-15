import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/env.dart';
import 'core/router.dart';
import 'core/supabase_init.dart';
import 'design/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Env.load();
  } catch (_) {
    // .env file missing — app still boots with defaults. Useful for
    // first-run / CI where keys haven't been provisioned yet.
  }
  await SupabaseInit.ensureInitialized();
  runApp(const ProviderScope(child: LokalApp()));
}

class LokalApp extends ConsumerWidget {
  const LokalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'LOKAL',
      debugShowCheckedModeBanner: false,
      theme: LokalTheme.light,
      routerConfig: router,
    );
  }
}
