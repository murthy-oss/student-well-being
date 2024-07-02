import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/navbar.dart';
import '../../constants.dart';
import '../../models/event_model.dart';
import '../../services/authentication/auth_service.dart';
import '../../utils/SizeConfig.dart';
import '../../widget_builders/events_builder.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> with TickerProviderStateMixin {
  late TabController _tabController;

  List<Event> myevents = [];
  List<Event> pastevents = [];
  List<Event> joinedEvents = [];
  String _userEmail = '';
  String email = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            SizedBox(
              width: SizeConfig.screenWidth * 0.04,
            ),
            Text(
              "My Events",
              style: kTitletextstyle.copyWith(
                  fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
        onItemTapped: (int value) {},
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Joined Event'),

              Tab(icon: Icon(Icons.check), text: 'Upcoming Events'),
              Tab(icon: Icon(Icons.pending_outlined), text: 'Past Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                Center(
                  child: myevents.isEmpty
                      ? Center(
                          child: Text(
                          "No upcoming events hosted by you",
                          style: ksubTextstyle,
                        ))
                      : event_builder(context, myevents, email, true),
                ),
                Center(
                  child: pastevents.isEmpty
                      ? Center(
                          child: Text(
                          "You haven't hosted any events yet",
                          style: ksubTextstyle,
                        ))
                      : event_builder(context, pastevents, email, false),
                  
                ),
                   Center(
                     child: 
                      joinedEvents.isEmpty
            ?
                     Center(
                                     child: Text(
                                     "You haven't joined any events yet",
                                     style: ksubTextstyle,
                                   ))
                                    : event_builder(context, joinedEvents, _userEmail, true),
                   )
           
   
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final _authService = AuthService();
      User? currentUser = await _authService.getCurrentUser();
      String? curemail = _authService.getCurrentUser()?.email;

      setState(() {
        email = curemail!;
      });

      // Fetch joined events
      await _fetchEventsFromFirestore(email);
      await _fetchPastEventsFromFirestore(email);
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

  Future<void> _fetchEventsFromFirestore(String userEmail) async {
    try {
      // Fetch events created by the current user
      QuerySnapshot userEventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('creater_email', isEqualTo: userEmail)
          .get();

      // Clear existing myevents list before adding new events
      setState(() {
        myevents.clear();
      });

      userEventsSnapshot.docs.forEach((eventDoc) {
        if (eventDoc.exists) {
          Event event = Event.fromFirestore(eventDoc);
          setState(() {
            myevents.add(event);
          });
        }
      });
    } catch (error) {
      print("Error fetching events: $error");
    }
  }

  Future<void> _fetchPastEventsFromFirestore(String userEmail) async {
    try {
      // Fetch events created by the current user
      QuerySnapshot userEventsSnapshot = await FirebaseFirestore.instance
          .collection('pastevents')
          .where('creater_email', isEqualTo: userEmail)
          .get();

      userEventsSnapshot.docs.forEach((eventDoc) {
        if (eventDoc.exists) {
          Event event = Event.fromFirestore(eventDoc);
          setState(() {
            pastevents.add(event);
          });
        }
      });
    } catch (error) {
      print("Error fetching events: $error");
    }
  }
}
