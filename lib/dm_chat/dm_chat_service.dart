import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dm_message_model.dart';

class DMChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // below code listens to user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // get user stream

  // send message
  Future<void> sendMessage(String receiverEmail, message) async {
    // get current user info,
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // create a new message
    DMMessage newMessage = DMMessage(
      senderEmail: currentUserEmail,
      receiverEmail: receiverEmail,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the 2 users

    List<String> ids = [currentUserEmail, receiverEmail];
    ids.sort(); // sort the ids(this ensures the chatroomID is the same for 2 people)
    String chatRoomID = ids.join('_');

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

// get message

  Stream<QuerySnapshot> getMessage(String userEmail, otherEmail) {
    // construct chat room ID for the 2 users

    List<String> ids = [userEmail, otherEmail];
    ids.sort(); // sort the ids(this ensures the chatroomID is the same for 2 people)
    String chatRoomID = ids.join('_');

    // add new message to database
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
