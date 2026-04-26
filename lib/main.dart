import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:story_app/l10n/app_localizations.dart';

import 'core/api/api_service.dart';
import 'core/preferences/auth_preferences.dart';
import 'core/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/story_repository.dart';
import 'presentation/auth/auth_provider.dart';
import 'presentation/auth/login/login_provider.dart';
import 'presentation/auth/register/register_provider.dart';
import 'presentation/story/add/add_story_provider.dart';
import 'presentation/story/list/story_list_provider.dart';
import 'presentation/settings/localization_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authPreferences = AuthPreferences();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthPreferences>(create: (_) => authPreferences),
        ProxyProvider<AuthPreferences, ApiService>(
          update: (context, prefs, previous) =>
              ApiService(prefs, onUnauthorized: () {}),
        ),
        ProxyProvider2<ApiService, AuthPreferences, AuthRepository>(
          update: (context, api, prefs, previous) => AuthRepository(api, prefs),
        ),
        ProxyProvider<ApiService, StoryRepository>(
          update: (context, api, previous) => StoryRepository(api),
        ),

        ChangeNotifierProxyProvider<AuthRepository, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
          update: (context, authRepo, authProvider) =>
              authProvider ?? AuthProvider(authRepo),
        ),
        ChangeNotifierProxyProvider<AuthRepository, LoginProvider>(
          create: (context) => LoginProvider(context.read<AuthRepository>()),
          update: (context, authRepo, previous) => LoginProvider(authRepo),
        ),
        ChangeNotifierProxyProvider<AuthRepository, RegisterProvider>(
          create: (context) => RegisterProvider(context.read<AuthRepository>()),
          update: (context, authRepo, previous) => RegisterProvider(authRepo),
        ),
        ChangeNotifierProxyProvider<StoryRepository, StoryListProvider>(
          create: (context) =>
              StoryListProvider(context.read<StoryRepository>()),
          update: (context, storyRepo, provider) =>
              provider ?? StoryListProvider(storyRepo),
        ),
        ChangeNotifierProxyProvider<StoryRepository, AddStoryProvider>(
          create: (context) =>
              AddStoryProvider(context.read<StoryRepository>()),
          update: (context, storyRepo, previous) => AddStoryProvider(storyRepo),
        ),
        ChangeNotifierProvider<LocalizationProvider>(
          create: (_) => LocalizationProvider(),
        ),
        Provider<AppRouter>(
          create: (context) => AppRouter(context.read<AuthProvider>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<ApiService>().onUnauthorized = () {
      context.read<AuthProvider>().logout();
    };
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = context.read<AppRouter>();

    return Consumer<LocalizationProvider>(
      builder: (context, locProvider, child) {
        return MaterialApp.router(
          locale: locProvider.locale,
          title: 'Story App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('id', '')],
          routerConfig: appRouter.router,
        );
      },
    );
  }
}
