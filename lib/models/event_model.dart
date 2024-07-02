import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  String hostName;
  final String createdby;
  final String creater_email;
  String title;
  DateTime dateTime;
  String mode;
  String location;
  String description;
  final List<String> coHostNames;
  List<String>? participants;
  List<String>? subgroups;
  List<String>? imageUrls;
  String? mainImageUrl; // For the main event photo

  String creatorid;

/*
  final double ticketPrice;
*/

  Event({
    required this.id,
    required this.creater_email,
    required this.createdby,
    required this.title,
    required this.hostName,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.mode,
    required this.coHostNames,
    this.participants,
    this.subgroups,
    this.imageUrls,
    this.mainImageUrl, // Initialize otherImageUrls

    required this.creatorid,
  });

  /*
    required this.ticketPrice,
*/

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse date and time from Firestore data
    DateTime? combinedDateTime;
    if (data['dateTime'] != null) {
      combinedDateTime = (data['dateTime'] as Timestamp).toDate();
    }

    /*



      */

    return Event(
      hostName: data['hostName'] ?? '',
      title: data['title'] ?? '',
      dateTime: combinedDateTime ?? DateTime.now(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      coHostNames: List<String>.from(data['coHostNames'] ?? []),
      createdby: data['createdby'] ?? '',
      creater_email: data['creater_email'] ?? '',
      participants: (data?['participants'] as List<dynamic>?)?.cast<String>(),
      id: doc.id,
      creatorid: data['creatorid'] ?? '',
      mode: data['mode'] ?? '',
      subgroups: List<String>.from(data['subgroups'] ?? []),
      imageUrls: List<String>.from(
          data['imageUrls'] ?? []), // Initialize imageUrls list
      mainImageUrl: data['mainimage'] ?? '', // Initialize mainImageUrl

      /*



      */
      /*
      ticketPrice: (data['ticketPrice'] ?? 0.0).toDouble(),
*/
    );
  }
}
