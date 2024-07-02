import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_welbeing/screens/AddEvent/add_event_page.dart';
import 'package:student_welbeing/screens/AddEvent/requestPage.dart';

import '../../provider/user_provider.dart';
import '../../services/authentication/auth_service.dart';

class ReqORAdd extends StatefulWidget {
  const ReqORAdd({Key? key}) : super(key: key);

  @override
  State<ReqORAdd> createState() => _ReqORAddState();
}

class _ReqORAddState extends State<ReqORAdd> {
  bool _isAuthorized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize the authorization status
    _initializeAuthorization();
  }

  void _initializeAuthorization() async {
    final AuthService _authService = AuthService();

    String userEmail = _authService.getCurrentUser()!.email!;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userEmail)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('isAuthorized')) {
          bool isAuthorizedByAdmin = data['isAuthorized'];

          Provider.of<UserProvider>(context, listen: false)
              .updateAuthorization(isAuthorizedByAdmin);
          setState(() {
            // Update the local variable with the value from the database
            _isAuthorized = isAuthorizedByAdmin;
            _isLoading = false; // Done loading
          });
          print('Authorization status: $_isAuthorized');
        } else {
          setState(() {
            // No 'isAuthorized' field found
            _isLoading = false; // Done loading
          });
          print('No authorization field found in Firestore');
        }
      } else {
        setState(() {
          // Snapshot doesn't exist or is null
          _isLoading = false; // Done loading
        });
        print('Snapshot does not exist or is null');
      }
    } catch (e) {
      setState(() {
        // Error fetching user data
        _isLoading = false; // Done loading
      });
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isAuthorized ? AddEventPage() : ReqAdmin();
  }
}
