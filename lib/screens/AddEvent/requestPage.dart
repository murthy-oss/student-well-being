import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_welbeing/screens/AddEvent/add_event_page.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';

import '../../components/myButton.dart';
import '../../components/navbar.dart';

class ReqAdmin extends StatefulWidget {
  ReqAdmin({Key? key}) : super(key: key);

  @override
  State<ReqAdmin> createState() => _ReqAdminState();
}

class _ReqAdminState extends State<ReqAdmin> {
  String UserEmail = FirebaseAuth.instance.currentUser!.email!;

  final CollectionReference userRequests =
      FirebaseFirestore.instance.collection('user_requests');

  // Function to handle the request admin button tap
  void requestAdmin() async {
    await userRequests.doc(UserEmail).set({
      'email': UserEmail,
    });

    print('Admin request sent successfully!');
  }

  void cancelRequest() async {
    await userRequests.doc(UserEmail).delete();
    print('Admin request cancelled successfully!');
  }

  Future<void> _refresh() async {
    // Manually refresh the page
    setState(() {});
  }

  late bool _isAuthorized = false;
  @override
  void initState() {
    super.initState();
    // Listen to changes in the authentication state
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(user.email)
                  .get();

          setState(() {
            _isAuthorized = userSnapshot['isAuthorized'];
          });
        } catch (e) {
          print('Error fetching authorization status: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: userRequests
              .doc(FirebaseAuth.instance.currentUser!.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator if snapshot is still loading
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.exists) {
              // Show message indicating that the request is pending and a cancel button
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You request is sent to admin. \nWaiting for approval.\n Try Refreshing",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ABC Diatype',
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                    ),
                  ),
                  SizedBox(height: 20),
                  MyButton(
                    onTap: cancelRequest,
                    text: 'Cancel Request',
                    color: Colors.red,
                  ),
                ],
              );
            } else if (!_isAuthorized) {
              // Show button to request admin if no request has been sent
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You are not authorized to post events.\nRequest Admin to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ABC Diatype',
                      fontWeight: FontWeight.w500,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.02,
                  ), // Add some spacing
                  MyButton(
                    onTap: () {
                      requestAdmin();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => ReqAdmin()));
                    },
                    text: 'Request Admin',
                    color: Colors.blue,
                  ),
                ],
              );
            } else {
              return AddEventPage();
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: (int value) {},
      ),
    );
  }
}
