import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../utils/SizeConfig.dart';
import 'package:icons_plus/icons_plus.dart';

class InvitationsScreen extends StatelessWidget {
  late final String? curUserEmail;
  InvitationsScreen({required this.curUserEmail});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Invitations',
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
      ),
      body: InvitationsListView(
        curUserEmail: curUserEmail,
      ),
    );
  }
}

// ignore: must_be_immutable
class InvitationsListView extends StatelessWidget {
  String? curUserEmail;

  InvitationsListView({required this.curUserEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('subgroups')
          .where('pendingInvitations',
              arrayContains:
                  curUserEmail) // Filter invitations by current user's ID
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No invitations found.'));
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.lightBlue[100],
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(data['name'] ?? 'Subgroup Name',
                      style: kTitletextstyle),
                  subtitle: Text(data['creator_email'] ?? 'Creator Email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Clarity.check_circle_line,
                          size: MediaQuery.of(context).size.width * (0.07),
                          color: Colors.green,
                        ),
                        onPressed: () => acceptInvitation(document.id),
                      ),
                      IconButton(
                        icon: Icon(
                          Clarity.close_line,
                          size: MediaQuery.of(context).size.width * (0.07),
                          color: Colors.red,
                        ),
                        onPressed: () => rejectInvitation(document.id),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void acceptInvitation(String subgroupID) async {
    try {
      // Get a reference to the subgroup document
      DocumentReference subgroupRef =
          FirebaseFirestore.instance.collection('subgroups').doc(subgroupID);

      // Add the current user's ID to the subgroup's participants list
      await subgroupRef.update({
        'participants': FieldValue.arrayUnion([curUserEmail]),
      });

      // Remove the current user's ID from the pending invitations list
      await subgroupRef.update({
        'pendingInvitations': FieldValue.arrayRemove([curUserEmail]),
      });

      print('Invitation accepted successfully!');
    } catch (e) {
      print('Error accepting invitation: $e');
    }
  }

  void rejectInvitation(String subgroupID) async {
    try {
      // Get a reference to the subgroup document
      DocumentReference subgroupRef =
          FirebaseFirestore.instance.collection('subgroups').doc(subgroupID);

      // Remove the current user's ID from the pending invitations list
      await subgroupRef.update({
        'pendingInvitations': FieldValue.arrayRemove([curUserEmail]),
      });

      print('Invitation rejected successfully!');
    } catch (e) {
      print('Error rejecting invitation: $e');
    }
  }
}
