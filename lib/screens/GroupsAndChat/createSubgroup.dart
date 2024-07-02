import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_welbeing/screens/GroupsAndChat/invites_page.dart';
import 'package:student_welbeing/screens/GroupsAndChat/subGroupChat.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';

import '../../constants.dart';
import '../../services/data_update/user_service.dart';
import '../../utils/SizeConfig.dart';

class CreateSubGroups extends StatefulWidget {
  final String eventId;
  CreateSubGroups({super.key, required this.eventId});

  @override
  State<CreateSubGroups> createState() => _CreateSubGroupsState();
}

class _CreateSubGroupsState extends State<CreateSubGroups> {
  AuthService _auth = AuthService();
  late String subgroupID;

  TextEditingController _subgroupNameController = TextEditingController();
  late String subgroupName;
  String? creatorEmail;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Event details',
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Subgroup Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _subgroupNameController,
              decoration: InputDecoration(labelText: 'Subgroup Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => createSubgroup(
                  widget.eventId, _subgroupNameController.text, creatorEmail!),
              child: Text('Create Subgroup'),
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
            ),
          ],
        ),
      ),
    );
  }

  // get user data
  Future<void> _loadUserData() async {
    try {
      User? currentUser = await _auth.getCurrentUser();

      creatorEmail = await _auth.getCurrentUser()!.email;
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

// Function to create a subgroup within an event
  Future<void> createSubgroup(
      String eventId, String subgroupName, String creatorEmail) async {
    try {
      // Reference to the Firestore collection "subgroups"
      CollectionReference subgroupsCollection =
          FirebaseFirestore.instance.collection('subgroups');

      // Create a new document for the subgroup
      DocumentReference subgroupDocRef = await subgroupsCollection.add({
        'eventId': eventId, // Reference to the parent event
        'name': subgroupName,
        'participants': [creatorEmail],
        'creatorEmail': creatorEmail, // Initially contains only the creator
      });
      subgroupID = subgroupDocRef.id;
      // Update the Event document to include the reference to the newly created subgroup
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update({
        'subgroups': FieldValue.arrayUnion([
          subgroupDocRef.id
        ]), // Add the subgroup ID to the event's subgroups list
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InviteParticipants(
                    eventId: eventId,
                    currentUserEmail: creatorEmail,
                    subgroupID: subgroupID,
                  )));
      print('Subgroup created successfully!');
    } catch (e) {
      print('Error creating subgroup: $e');
    }
  }
}
