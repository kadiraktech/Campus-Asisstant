import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectv1/src/features/home/presentation/screens/home_screen.dart';
import 'package:projectv1/src/features/auth/presentation/screens/login_screen.dart'; // Ensure LoginScreen is imported

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not logged in
        if (!snapshot.hasData) {
          return const LoginScreen(); // Show login screen if not logged in
        }

        // User is logged in
        return const HomeScreen(); // Show home screen if logged in
      },
    );
  }
}
