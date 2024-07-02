import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/dm_chat/dm_chatPage.dart';

import '../../services/authentication/auth_service.dart';
import '../../services/data_update/user_service.dart';
import '../../utils/SizeConfig.dart';

class ParticipantsPage extends StatefulWidget {
  final String eventId;

  ParticipantsPage({required this.eventId});

  @override
  _ParticipantsPageState createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Participants',
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> eventSnapshot) {
          if (eventSnapshot.hasError ||
              !eventSnapshot.hasData ||
              !eventSnapshot.data!.exists) {
            return Center(
              child: Text('Error: Event not found'),
            );
          }

          var eventData = eventSnapshot.data!.data() as Map<String, dynamic>;
          List<String> participantUids =
              List.from(eventData['participants'] ?? []);

          if (participantUids.isEmpty) {
            return Center(
              child: Text('No participants found.'),
            );
          }

          return UsersListView(userEmails: participantUids);
        },
      ),
    );
  }
}

class UsersListView extends StatelessWidget {
  AuthService _auth = AuthService();

  final List<String> userEmails;

  UsersListView({required this.userEmails});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userEmails.length,
      itemBuilder: (BuildContext context, int index) {
        final String partEmail = userEmails[index];
        if (partEmail == _auth.getCurrentUser()?.email) {
          // Skip rendering the tile if it's the current user
          return SizedBox.shrink();
        }
        return FutureBuilder(
          future: _getUserData(userEmails[index]),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                !snapshot.data!.exists) {
              return Text('Error: Unable to fetch user data');
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlue[100],
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  DMChatPage(
                            receiverEmail: userData['email'],
                            receivername: userData['name'],
                          ),
                          transitionDuration: Duration(milliseconds: 200),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      _showReportDialog(context, userData['email'],
                          _auth.getCurrentUser()!.email!);
                    },
                    icon: Icon(
                      EvaIcons.alert_circle_outline,
                      color: Colors.red,
                    ),
                  ),
                  title: Text(userData['name'] ?? 'Name not available',
                      style: kTitletextstyle),
                  //subtitle: Text(userData['email'] ?? 'Email not available'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<DocumentSnapshot> _getUserData(String uid) async {
    return await FirebaseFirestore.instance.collection('Users').doc(uid).get();
  }

  void _showReportDialog(
      BuildContext context, String badEmail, String goodEmail) {
    TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report User"),
          content: TextField(
            controller: reportController,
            decoration: InputDecoration(hintText: "Enter report message"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Send"),
              onPressed: () {
                String message = reportController.text;
                reportUser(badEmail, message, goodEmail);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> reportUser(
      String badEmail, String message, String goodEmail) async {
    try {
      final CollectionReference reportRef =
          FirebaseFirestore.instance.collection('reports');

      // Generate a unique report ID
      final String reportId = reportRef.doc().id;

      // Create a report object
      final Map<String, dynamic> reportData = {
        'badEmail': badEmail,
        'message': message,
        'timestamp': DateTime.now(),
        'reporter': goodEmail
      };

      // Save the report to the database
      await reportRef.doc(reportId).set(reportData);

      print('User $badEmail reported successfully.');
    } catch (e) {
      print('Error reporting user: $e');
    }
  }
}
