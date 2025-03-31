import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; // For Google Sign-In
import 'package:shop_local/views/home_page.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // Schedule navigation after current build frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Your Firebase UI login screen implementation
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
      },
    );
  }
}