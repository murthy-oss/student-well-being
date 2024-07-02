import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String? senderEmail; // Optional, as sender may not always have an email
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderID,
    this.senderEmail,
    required this.message,
    required this.timestamp,
  });

  // Convert message to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail':
          senderEmail ?? "", // Use empty string if senderEmail is null
      'message': message,
      'timestamp': timestamp,
    };
  }

  // Create a message object from a map retrieved from Firestore
  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? "",
      senderEmail: map['senderEmail'],
      message: map['message'] ?? "",
      timestamp: map['timestamp'],
    );
  }
}
