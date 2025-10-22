import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_provider.dart';
import 'src/core/providers/default_city_provider.dart';
import 'package:projectv1/src/features/auth/presentation/screens/login_screen.dart';
import 'package:projectv1/src/features/home/presentation/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projectv1/src/core/providers/default_city_provider.dart';
import 'package:projectv1/src/core/theme/app_theme.dart';
import 'package:projectv1/src/core/theme/theme_provider.dart';
import 'package:projectv1/src/features/auth/presentation/screens/auth_gate.dart';
import 'package:projectv1/src/core/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:projectv1/generated/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Import LocaleProvider
import 'src/core/providers/locale_provider.dart';

// Import for DateFormat initialization
import 'package:intl/date_symbol_data_local.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Timezones
  tz.initializeTimeZones();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize date formatting
  await initializeDateFormatting('tr_TR', null); // Initialize for Turkish
  await initializeDateFormatting(
    'en_US',
    null,
  ); // Initialize for English (or your default)

  // Initialize providers
  final themeProvider = ThemeProvider(); // Loads theme in constructor
  final cityProvider = DefaultCityProvider();
  final localeProvider = LocaleProvider(); // Initialize LocaleProvider

  // Load initial preferences asynchronously
  // Note: LocaleProvider loads its own state in its constructor
  await cityProvider.loadCity();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: cityProvider),
        ChangeNotifierProvider.value(
          value: localeProvider,
        ), // Add LocaleProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // No need for MultiProvider here as it's already provided above main runApp
    // Access providers using Consumer or context.watch/read
    return Consumer<ThemeProvider>(
      // Consume ThemeProvider
      builder: (context, themeProvider, child) {
        // Use context.watch for LocaleProvider to rebuild on locale change
        final localeProvider = context.watch<LocaleProvider>();

        return MaterialApp(
          title: 'Campus Assistant',
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: localeProvider.locale, // Set locale from provider
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:
              AppLocalizations.supportedLocales, // Use generated list
          home: const AuthGate(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Provide a Scaffold or Material basic structure during loading
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
