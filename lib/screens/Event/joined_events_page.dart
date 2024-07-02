import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_welbeing/components/navbar.dart';
import 'package:student_welbeing/models/event_model.dart';
import '../../constants.dart';
import '../../services/authentication/auth_service.dart';
import '../../services/data_update/user_service.dart';
import '../../utils/SizeConfig.dart';
import '../../widget_builders/events_builder.dart';

class JoinedEventsPage extends StatefulWidget {
  const JoinedEventsPage({Key? key}) : super(key: key);

  @override
  State<JoinedEventsPage> createState() => _JoinedEventsPageState();
}

class _JoinedEventsPageState extends State<JoinedEventsPage> {
  List<Event> joinedEvents = [];
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final width = SizeConfig.screenWidth;

    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Yes, exit'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
        return value == true;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 2,
          onItemTapped: (int value) {},
        ),
        appBar: AppBar(
          title: Row(
            children: [
              SizedBox(
                width: width * 0.04,
              ),
              Text(
                "Joined Events",
                style: kTitletextstyle.copyWith(
                    fontSize: SizeConfig.screenWidth * 0.05,
                    color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: joinedEvents.isEmpty
            ? Center(
                child: Text(
                "You haven't joined any events yet",
                style: ksubTextstyle,
              ))
            : event_builder(context, joinedEvents, _userEmail, true),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final _authService = AuthService();
      User? currentUser = await _authService.getCurrentUser();

      final userService = UserService();
      final userEmail = await _authService.getCurrentUser()?.email;
      setState(() {
        _userEmail = userEmail!;
      });

      // Fetch joined events
      await _fetchEventsFromFirestore(userEmail!);
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

  Future<void> _fetchEventsFromFirestore(String userEmail) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .get();

    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userData != null) {
      List<String> joinedEventIds =
          List<String>.from(userData['joinedEvents'] ?? []);

      for (String eventId in joinedEventIds) {
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();
        if (eventDoc.exists) {
          Event event = Event.fromFirestore(eventDoc);
          setState(() {
            joinedEvents.add(event);
          });
        }
      }
    }
  }
}
