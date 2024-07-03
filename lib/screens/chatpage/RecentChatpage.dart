import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_welbeing/screens/chatpage/ChatScreen.dart';

class RecentChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid)
       // .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recent chats.'));
        }

        final chatRooms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            final messagesCollection = FirebaseFirestore.instance
                .collection('chatRooms')
                
                ;

            return StreamBuilder<QuerySnapshot>(
              stream: messagesCollection
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, messagesSnapshot) {
                if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (messagesSnapshot.hasError) {
                  print(messagesSnapshot.error);
                  return Center(child: Text('Error: ${messagesSnapshot.error}'));
                }

                // Extract the latest message if available
                final recentMessage = chatRoom['recentMessage']==null
                    ? 'No messages'
                    : chatRoom['recentMessage'];

                final users = chatRoom['users'] as List<dynamic>;
                final otherUserUid =
                    users.firstWhere((uid) => uid != FirebaseAuth.instance.currentUser!.uid);
                print(otherUserUid);
final otherUserSnapshot = FirebaseFirestore.instance.collection('Users').where('uid', isEqualTo: otherUserUid).snapshots();

            return StreamBuilder<QuerySnapshot>(
              stream: otherUserSnapshot ,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('User data not found.'));
                }

                final otherUserSnapshotData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatRoomId: chatRoom.id,
                          UserName: otherUserSnapshotData['name'],
                          ProfilePicture: otherUserSnapshotData['imageLink'] ?? '',
                          UId: otherUserUid,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: otherUserSnapshotData['imageLink'] != null
                        ? NetworkImage(otherUserSnapshotData['imageLink'])
                        : AssetImage('assets/images/img_2.png') as ImageProvider,
                  ),
                  title: Text(otherUserSnapshotData['name'] ?? 'Unknown User'),
                  subtitle: Text(recentMessage),
                );
              },
            );
        //   },
        // );
              },
            );
          },
        );
      },
    );
  }
}
