import 'package:cloud_firestore/cloud_firestore.dart';

class DMMessage {
  final String? senderEmail;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;

  DMMessage({
    required this.senderEmail,
    required this.receiverEmail,
    required this.message,
    required this.timestamp,
  });

  // convert to a map

  Map<String, dynamic> toMap() {
    return {
      'senderEmail': senderEmail,
      'timestamp': timestamp,
      'message': message,
      'receiverID': receiverEmail,
    };
  }
}
