import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider with ChangeNotifier {
  late DocumentReference<Map<String, dynamic>> _userDocumentRef;
  User? _user;
  bool _isAuthorized = false;

  List<String> _joinedEvents = []; // New field to store joined events
  bool _isUserDataLoaded = false;

  bool get isUserDataLoaded => _isUserDataLoaded;

  List<String> get joinedEvents => _joinedEvents; // Getter for joinedEvents
  bool get isAuthorized => _isAuthorized;

  late StreamController<bool> _authorizationController;

  UserProvider() {
    _authorizationController = StreamController<bool>.broadcast();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user != null) {
        try {
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user!.uid)
                  .get();

          _joinedEvents = List<String>.from(userSnapshot['joinedEvents'] ?? []);

          _isUserDataLoaded = true;
          _isAuthorized = userSnapshot['isAuthorized'] ?? false;
          notifyListeners();
        } catch (e) {
          print('Error fetching user data: $e');
        }
      } else {
        _joinedEvents = []; // Reset joinedEvents list
        _isUserDataLoaded = false;
        _isAuthorized = false;
        notifyListeners();
      }
    });

    // Initialize authorization status
    _authorizationController.add(_isAuthorized);
  }

  void clearUserData() {
    _user = null;

    _joinedEvents = []; // Reset joinedEvents list
    _isUserDataLoaded = false;
    notifyListeners();
  }

  // Method to join an event and update joinedEvents list
  void updatejoinedEvent(String eventId) async {
    try {
      // Add the event ID to the joinedEvents list
      _joinedEvents.add(eventId);

      // Update the joinedEvents list in Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user!.uid)
          .update({
        'joinedEvents': _joinedEvents,
      });

      notifyListeners();
    } catch (error) {
      print('Error joining event: $error');
    }
  }

  void updateAuthorization(bool isAuthorized) {
    _isAuthorized = isAuthorized;
    // Add the updated authorization status to the stream
    _authorizationController.add(_isAuthorized);
    notifyListeners();
  }

  // Stream getter for authorization status
  Stream<bool> get authorizationStream => _authorizationController.stream;

  @override
  void dispose() {
    _authorizationController.close(); // Close the stream controller
    super.dispose();
  }
}
