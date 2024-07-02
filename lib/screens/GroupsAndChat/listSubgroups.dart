import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/screens/GroupsAndChat/subGroupChat.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';
import 'package:student_welbeing/services/data_update/user_service.dart';

import '../../utils/SizeConfig.dart';

class SubgroupList extends StatefulWidget {
  final String eventId;
  SubgroupList({
    required this.eventId,
  });

  @override
  State<SubgroupList> createState() => _SubgroupListState();
}

class _SubgroupListState extends State<SubgroupList> {
  AuthService _auth = AuthService();
  String? email;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Subgroups',
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
      ),
      body: _buildSubgroupList(context),
    );
  }

  Widget _buildSubgroupList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('subgroups')
          .where('eventId',
              isEqualTo: widget.eventId) // Filter subgroups by event ID
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No subgroups found for this event.'),
          );
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.lightBlue[100],
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name: " + data['name'],
                                    style: kTitletextstyle,
                                  ),
                                  Text(
                                    "Created By: " + data['creatorEmail'],
                                    style: kTitletextstyle.copyWith(
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /*Icon(Clarity.sign_in_line),*/
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff8fbc8f),
                                  foregroundColor: Colors.white,
                                  shadowColor: Color(0xff8fbc8f),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.sizeOf(context).width *
                                            0.03),
                                    side: BorderSide(
                                        color: Colors.black, width: 1),
                                  ),
                                  elevation: 5,
                                ),
                                onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SubGroupChatPage(
                                          eventId: widget.eventId,
                                          currentUserEmail: email!,
                                          subgroupID: document.id,
                                        ),
                                      ),
                                    ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Enter subgroup'),
                                    Icon(Clarity.sign_in_line),
                                  ],
                                )),
                          ),
                          FutureBuilder<bool>(
                            future: isCurrentUserSubgroupCreator(document.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                if (snapshot.hasData && snapshot.data == true) {
                                  return Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.35,
                                    child: Expanded(
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFFF625C),
                                            foregroundColor: Colors.white,
                                            shadowColor: Color(0xFFFF625C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      MediaQuery.sizeOf(context)
                                                              .width *
                                                          0.03),
                                              side: BorderSide(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                            elevation: 5,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Delete'),
                                              Icon(Clarity.trash_line),
                                            ],
                                          ),
                                          onPressed: () => showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirm Delete'),
                                                  content: Text(
                                                      "Are you sure you want to delete this subgroup?"),
                                                  actions: [
                                                    TextButton(
                                                      child: Text("Cancel"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        deleteSubgroup(
                                                            document.id);
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              })),
                                    ),
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {},
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void loadUserData() async {
    email = await _auth.getCurrentUser()?.email;
  }

  Future<bool> isCurrentUserSubgroupCreator(String subgroupID) async {
    try {
      // Reference to the subgroup document
      DocumentSnapshot subgroupSnapshot = await FirebaseFirestore.instance
          .collection('subgroups')
          .doc(subgroupID)
          .get();

      if (subgroupSnapshot.exists && subgroupSnapshot.data() != null) {
        // Get the data map from the subgroup document
        Map<String, dynamic>? data =
            subgroupSnapshot.data() as Map<String, dynamic>?;

        // Check if the data map contains the creatorEmail field
        if (data != null && data.containsKey('creatorEmail')) {
          // Get the creatorEmail from the data map
          String creatorEmail = data['creatorEmail'];

          // Compare the current user's ID with the creatorEmail
          return email == creatorEmail;
        }
      }

      // Subgroup document doesn't exist, or creatorEmail field is missing
      // Handle this case based on your application's logic
      return false;
    } catch (e) {
      // Error occurred while checking the creator
      print('Error checking subgroup creator: $e');
      // Handle the error appropriately
      return false;
    }
  }

  Future<void> deleteSubgroup(String subgroupID) async {
    try {
      // Reference to the subgroup document
      DocumentReference subgroupRef =
          FirebaseFirestore.instance.collection('subgroups').doc(subgroupID);

      // Delete the subgroup document
      await subgroupRef.delete();

      print('Subgroup deleted successfully!');
    } catch (e) {
      print('Error deleting subgroup: $e');
    }
  }
}
