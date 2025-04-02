import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_local/controller/Authetication_Phase.dart';
import 'package:shop_local/view/home_page.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firebase UI
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: '431763454927-jnc9ogsiqeai9togjp96ah1170fhjf90.apps.googleusercontent.com'), // For web Google Sign-In
    // Add other providers as needed
  ]);
  runApp(const ShopLocalApp());
}



class ShopLocalApp extends StatefulWidget {
  const ShopLocalApp({super.key});

  @override
  State<ShopLocalApp> createState() => _ShopLocalAppState();
}

class _ShopLocalAppState extends State<ShopLocalApp>{
  // This widget is the root of your application.
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthGate(),
            '/home': (context) => HomePage(
              onThemeChanged: (isDark) {
                _themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          },
        );
      },
    );
  }
}