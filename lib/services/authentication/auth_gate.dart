import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_welbeing/screens/Login_Register/login_page.dart';
import '../../screens/Home/home_page.dart';
import 'package:student_welbeing/screens/Login_Register/email_not_verified.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        if (user.emailVerified) {
          // Email is verified, check if user is registered
          checkRegistrationStatus(user);
        } else {
          // Email is not verified, navigate to EmailNotVerifiedPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EmailNotVerifiedPage(
                      email: user.email.toString(),
                    )),
          );
        }
      }
    });
  }

  Future<void> checkRegistrationStatus(User user) async {
    // Replace this with your logic to check if the user is registered
    // For example, you can query your database to check if the user exists
    // and if their registration status is confirmed
    // Navigate to home screen if registered, else navigate to register page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // user is logged in
            if (snapshot.hasData) {
              return HomePage();
            } else {
              return LoginPage();
            }
          }),
    );
  }
}
