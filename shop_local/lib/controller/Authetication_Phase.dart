import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import '../view/directory_screen.dart';// Screen for login/sign up
// import '../view/login_screen.dart';// Screen for diary log
import '../views/introduction.dart';
import '../views/home_page.dart';// Screen for introduction

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to changes in the authentication state (user logged in or out)
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, the user is logged in
        if (snapshot.hasData) {
          return  HomePage(
            onThemeChanged: (isDark) {
              // Handle theme change if needed
            },);
        }
        // If no user data is present, show the login screen
        return  IntroductionScreen();
      },
    );
  }
}