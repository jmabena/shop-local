// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:shop_local/controller/Authetication_Phase.dart';
// // import 'package:shop_local/view/login_screen.dart';
// import '../view/login_screen.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
   
//   );
//   runApp(const ShopLocalApp());
// }



// class ShopLocalApp extends StatelessWidget {
//   const ShopLocalApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ShopLocalApp',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
//       ),
//       home: AuthGate(),
//       // routes: { '/login': (context) => const LoginScreen()},
//       routes: {
//     '/login': (context) => LoginScreen(),
//     // other routes...
//   },
//     );
//   }
// }



import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shop_local/controller/Authetication_Phase.dart';
import 'package:shop_local/view/home_page.dart';
import 'package:shop_local/view/login_screen.dart';
import 'controller/deals_controller.dart';
import 'controller/seller_controller.dart';
import 'controller/user_controller.dart';
import 'controller/news_controller.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase only if no apps exist
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    
    // Configure FirebaseUI
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      GoogleProvider(clientId: ''), // Add your Google client ID if needed
    ]);
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DealsController()),
        ChangeNotifierProvider(create: (_) => SellerController()),
        ChangeNotifierProvider(create: (_) => NewsController())  
      ],
      child: const ShopLocalApp(),
    ),
  );
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
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}