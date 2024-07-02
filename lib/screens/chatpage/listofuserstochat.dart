import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_welbeing/components/navbar.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/screens/chatpage/ChatScreen.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';

class ListOfUsersToChat extends StatelessWidget {
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
              "Chat",
              style: kTitletextstyle.copyWith(
                  fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onItemTapped: (int value) {},
      ),
      body: UsersList(),
    );
  }
}

class UsersList extends StatelessWidget {
  void createChatRoom(BuildContext context, Map<String, dynamic> userData) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    String targetUserUid = userData['uid'];
    String targetUserName = userData['name'] ?? '';
    String targetUserProfile = userData['imageLink'] ?? '';

    // Create a unique chat room ID based on user UIDs
    String chatRoomId = currentUserUid.hashCode <= targetUserUid.hashCode
        ? '$currentUserUid-$targetUserUid'
        : '$targetUserUid-$currentUserUid';

    // Check if the chat room already exists
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .get()
        .then((chatRoomSnapshot) {
      if (chatRoomSnapshot.exists) {
        // Chat room already exists, navigate to chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: chatRoomId,
              UserName: targetUserName,
              ProfilePicture: targetUserProfile,
              UId: targetUserUid,
            ),
          ),
        );
      } else {
        // Chat room doesn't exist, create and navigate to chat screen
        FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).set({
          'users': [currentUserUid, targetUserUid],
          'createdAt': FieldValue.serverTimestamp(),
          'recentMessage': "tap to chat"
        }).then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatRoomId: chatRoomId,
                UserName: targetUserName,
                ProfilePicture: targetUserProfile,
                UId: targetUserUid,
              ),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found.'));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final name = user['name'];
            //final imageLink = user['imageLink'];

            return ListTile(
              onTap: () {
                createChatRoom(context, user.data() as Map<String, dynamic>);
              },
              title: Text(name),
              // leading: CircleAvatar(
              //   backgroundImage: imageLink != null ? NetworkImage(imageLink) : AssetImage('assets/images/img_2.png') as ImageProvider,
              // ),
            );
          },
        );
      },
    );
  }
}
