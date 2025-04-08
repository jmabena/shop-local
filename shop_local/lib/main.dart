import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_local/controller/Authetication_Phase.dart';
import 'package:shop_local/views/login_screen.dart';

import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShopLocalApp());
}



class ShopLocalApp extends StatelessWidget {
  const ShopLocalApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopLocalApp',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: AuthGate(),
      routes: { '/login': (context) => const LoginScreen()},
    );
  }
}