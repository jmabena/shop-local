import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

import '../create_dummy_data.dart';
import '../view/directory_screen.dart';// Screen for login/sign up
import '../view/login_screen.dart';// Screen for diary log

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to changes in the authentication state (user logged in or out)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          // Schedule navigation after current build frame
          //final dummyDataGenerator = DummyDataGenerator();
          //dummyDataGenerator.generateDummyData();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return SignInScreen(
          providers: [
            EmailAuthProvider(),
            GoogleProvider(clientId: '431763454927-jnc9ogsiqeai9togjp96ah1170fhjf90.apps.googleusercontent.com'),
          ],
          headerBuilder: (context, constraints, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/bg.jpg'), // Add your logo
            );
          },
          footerBuilder: (context, action) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our terms and conditions.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          },
          sideBuilder: (context, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset('assets/bg.jpg'),
            );
          },
        );
        // If the snapshot has user data, the user is logged in
        // if (snapshot.hasData) {
        //   return  BusinessDirectoryPage();
        // }
        // // If no user data is present, show the login screen
        // return const LoginScreen();
        //
      },
    );
  }
}