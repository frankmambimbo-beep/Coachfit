import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/profile/domain/user_profile.dart';
import 'features/profile/data/profile_repository.dart';

// App entry point. This runs before anything else.
Future<void> main() async {
  // Required when you do async work (like Hive setup) before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive — our local, offline database.
  await Hive.initFlutter();

  // Register each custom type so Hive knows how to save/load it.
  // (These "adapters" are normally auto-generated, but we hand-wrote
  // them since this phone/CI setup can't run the code generator.)
  Hive.registerAdapter(FitnessLevelAdapter());
  Hive.registerAdapter(PrimaryGoalAdapter());
  Hive.registerAdapter(WorkoutLocationAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  // Open the "box" (like a table) that stores the user's profile.
  await Hive.openBox<UserProfile>(profileBoxName);

  // ProviderScope makes Riverpod state available to the whole app.
  runApp(const ProviderScope(child: CoachFitApp()));
}

class CoachFitApp extends ConsumerWidget {
  const CoachFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the router provider means the app rebuilds if routing
    // logic depends on state that changes (e.g. profile created).
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CoachFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router, // hands navigation control to go_router
    );
  }
}
