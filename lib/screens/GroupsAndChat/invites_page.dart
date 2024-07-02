import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:student_welbeing/screens/GroupsAndChat/subGroupChat.dart';

import '../../constants.dart';
import '../../utils/SizeConfig.dart';

class InviteParticipants extends StatefulWidget {
  final String eventId;
  final String subgroupID;
  final String currentUserEmail;
  const InviteParticipants(
      {super.key,
      required this.eventId,
      required this.subgroupID,
      required this.currentUserEmail});

  @override
  State<InviteParticipants> createState() => _InviteParticipantsState();
}

class _InviteParticipantsState extends State<InviteParticipants> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Invite Participants',
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
          List<String> participantEmails =
              List.from(eventData['participants'] ?? []);

          if (participantEmails.isEmpty) {
            return Center(
              child: Text('No participants found.'),
            );
          }

          return UsersListView(
            userEmails: participantEmails,
            subgroupID: widget.subgroupID,
          );
        },
      ),
      persistentFooterButtons: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8fbc8f),
              foregroundColor: Colors.white,
              shadowColor: Color(0xff8fbc8f),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    MediaQuery.sizeOf(context).width * 0.03),
                side: BorderSide(color: Colors.black, width: 1),
              ),
              elevation: 5,
            ),
            onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubGroupChatPage(
                        eventId: widget.eventId,
                        currentUserEmail: widget.currentUserEmail,
                        subgroupID: widget.subgroupID),
                  ),
                ),
            child: Text('Continue to SubGroup'))
      ],
    );
  }
}

class UsersListView extends StatelessWidget {
  final List<String> userEmails;
  final String subgroupID;
  UsersListView({required this.userEmails, required this.subgroupID});
  void inviteParticipantToSubgroup(
      String subgroupID, String participantUID) async {
    try {
      // Reference to the subgroup document
      DocumentReference subgroupRef =
          FirebaseFirestore.instance.collection('subgroups').doc(subgroupID);

      // Add the participant's UID to the pending invitations list
      await subgroupRef.update({
        'pendingInvitations': FieldValue.arrayUnion([participantUID]),
      });

      print('Invitation sent successfully!');
    } catch (e) {
      print('Error sending invitation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: userEmails.length,
      itemBuilder: (BuildContext context, int index) {
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
                  trailing: IconButton(
                    onPressed: () => inviteParticipantToSubgroup(
                        subgroupID, userData['uid']),
                    icon: Icon(
                      Clarity.add_text_line,
                      size: MediaQuery.of(context).size.width * (0.07),
                    ),
                  ),
                  title: Text(userData['name'] ?? 'Name not available',
                      style: kTitletextstyle),
                  subtitle: Text(userData['email'] ?? 'Email not available'),
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
}
