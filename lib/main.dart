// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_welbeing/key/navigatorkey.dart';
import 'package:student_welbeing/provider/event_provider.dart';
import 'package:student_welbeing/provider/floating_window_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_welbeing/provider/user_provider.dart';
import 'package:student_welbeing/services/authentication/auth_gate.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseStorage storage = FirebaseStorage.instance;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    AuthService authService =
        AuthService(); // Instantiate your authentication service
    User? currentUser = authService.getCurrentUser();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FloatingWindowProvider()),
        ChangeNotifierProvider.value(
          value:
              UserProvider(), // No need to pass initial user, userName, or profileImageUrl
        ),

        ChangeNotifierProvider(
            create: (_) => EventProvider()), // Provide EventProvider
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Student Wellbeing',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthGate(), // Your main authentication page
      ),
    );
  }
}
