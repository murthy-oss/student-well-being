import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../key/navigatorkey.dart';
import '../../provider/user_provider.dart';
import '../../screens/Login_Register/login_page.dart';
import '../data_update/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

final UserService _userService = UserService();

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? getCurrentUser() {
    return _auth.currentUser;
  }
// Verify email

  Future<bool> isEmailVerified(String email) async {
    try {
      User? user = getCurrentUser();
      await user!.reload(); // Reload the user to get the latest data
      return user.emailVerified;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Sign in
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user's email is verified
      if (!userCredential.user!.emailVerified) {
        throw FirebaseAuthException(
          code: 'email_not_verified',
          message: 'Please verify your email before proceeding.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    User? user = getCurrentUser();
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    Provider.of<UserProvider>(context, listen: false).clearUserData;
    clearCachedData();

/*
    return await _auth.signOut();
*/
  }

  Future<void> signOutT() async {
    clearCachedData();
    /*return await _auth.signOut();*/
  }
  // SIgn UP

  Future<void> signUpWithEmailPassword(
      String email, String password, String name) async {
    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Add user to Firestore

      await _userService.addUserToFirestore(
          userCredential.user!.uid, email, name,userCredential.user?.photoURL);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

/*  Future<String> getCurrentUserName() async {
    try {
      User? currentUser = getCurrentUser();
      if (currentUser != null) {
        return await _userService.getCurrentUserName();
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error getting current user's name: $e");
      return 'Unknown';
    }
  }*/

/*  Future<String> getCurrentUserEmail() async {
    try {
      User? currentUser = getCurrentUser();
      if (currentUser != null) {
        return await _userService.getCurrentUserEmail(currentUser.email);
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error getting current user's email: $e");
      return 'Unknown';
    }
  }*/

  Future<bool?> getIsAuthorized() async {
    try {
      // Get the document snapshot for the user
      User? user = getCurrentUser();
      String userEmail = user!.email!;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userEmail)
          .get();

      // Check if the snapshot exists and contains the 'isAuthorized' field
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('isAuthorized')) {
          // Return the value of 'isAuthorized' field
          return data['isAuthorized'];
        }
      }
      // If the 'isAuthorized' field is not found, return null or a default value
      return false;
    } catch (e) {
      // Handle any errors
      print("Error fetching isAuthorized data: $e");
      return false;
    }
  }

  Future<String?> getCurrentUserID() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // If the user is not null, return the UID, else return null
    return user?.uid;
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // If the user is new, add their data to the Firestore Users collection
        if (userCredential.additionalUserInfo!.isNewUser) {
          await _userService.addUserToFirestore(
            userCredential.user!.uid,
            userCredential.user!.email!,
            userCredential.user!.displayName ?? 'Unknown',
            userCredential.user!.photoURL??'https://static-00.iconduck.com/assets.00/user-icon-2048x2048-ihoxz4vq.png'
            // You can add other user data as needed
          );
        }
      }
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }

  late StreamSubscription<DocumentSnapshot> _userSubscription;

  AuthService() {
    _initializeUserDocumentListener();
  }

  void _initializeUserDocumentListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToUserDocument(user.email!);
      } else {
        _cancelUserDocumentListener();
      }
    });
  }

  void _listenToUserDocument(String userEmail) {
    _userService
        .getUserDocumentStream(userEmail)
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Cast data to Map<String, dynamic>
        Map<String, dynamic>? userData =
            snapshot.data() as Map<String, dynamic>?;

        // Check if userData is not null
        if (userData != null) {
          // Check if the 'disabled' field is true
          bool disabled = userData['disabled'] ?? false;
          if (disabled) {
            // Log out the user if disabled
            print('User is disabled. Logging out...');
            signOutT().then((_) {
              // Navigate to the login screen after logging out
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      LoginPage(), // Replace LoginPage with your actual login screen
                ),
              );
            }).catchError((error) {
              // Handle error while logging out
              print('Error logging out: $error');
            });
          }
        }
      }
    });
  }

  // Cancel the user document listener
  void _cancelUserDocumentListener() {
    _userSubscription.cancel();
  }

  Future<void> clearCachedData() async {
    try {
      // Clear SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear cached files
      await DefaultCacheManager().emptyCache();

      // Sign out from Firebase
      await _auth.signOut();

      // Optionally, you can navigate the user to the login screen after clearing cached data
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              LoginPage(), // Replace LoginPage with your actual login screen
        ),
      );
    } catch (error) {
      print('Error clearing cached data: $error');
    }
  }
}
