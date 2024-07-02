import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/event_model.dart';
import '../models/group_message_model.dart';

class GroupChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send message to event group chat
  Future<void> sendMessageToEventChat(String eventID, String message) async {
    try {
      final String currentUserID = _auth.currentUser!.uid;
      final String? currentUserEmail = _auth.currentUser!.email;
      final Timestamp timestamp = Timestamp.now();

      // Create message object with sender's name
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        message: message,
        timestamp: timestamp,
      );

      // Use the event ID as the chat room ID
      String eventChatRoomID = eventID;

      // Add message to Firestore
      await _firestore
          .collection("event_chat_rooms")
          .doc(eventChatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get messages from event group chat
  Stream<QuerySnapshot<Map<String, dynamic>>> getEventChatMessages(
      String eventID) {
    String eventChatRoomID = eventID;
    return _firestore
        .collection("event_chat_rooms")
        .doc(eventChatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Method to fetch event details
  Future<Event?> getEvent(String eventID) async {
    try {
      DocumentSnapshot eventSnapshot =
          await _firestore.collection("events").doc(eventID).get();
      if (eventSnapshot.exists) {
        return Event.fromFirestore(eventSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching event: $e");
      return null;
    }
  }

  Future<void> sendMessageToSubgroupChat(
      String eventID, String subgroupID, String message) async {
    try {
      final String currentUserID = _auth.currentUser!.uid;
      final String? currentUserEmail = _auth.currentUser!.email;
      final Timestamp timestamp = Timestamp.now();

      // Create message object with sender's name
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        message: message,
        timestamp: timestamp,
      );

      // Use the event ID and subgroup ID as the chat room ID
      String subgroupChatRoomID = '$eventID-$subgroupID';

      // Add message to Firestore
      await _firestore
          .collection("subgroup_chat_rooms")
          .doc(subgroupChatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get messages from subgroup chat
  Stream<QuerySnapshot<Map<String, dynamic>>> getSubgroupChatMessages(
      String eventID, String subgroupID) {
    String subgroupChatRoomID = '$eventID-$subgroupID';
    return _firestore
        .collection("subgroup_chat_rooms")
        .doc(subgroupChatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
