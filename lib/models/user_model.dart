import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String name;
  final String id;
  final String email;
  late String imageUrl;
  List<String> joinedEvents;
  final bool isAuthorized; // New field to store joined events

  Users({
    required this.isAuthorized,
    required this.name,
    required this.id,
    required this.email,
    required this.imageUrl,
    List<String>? joinedEvents, // Updated constructor to accept joined events
  }) : joinedEvents = joinedEvents ?? [];

  //
  //
  //
  //

  factory Users.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Users(
      name: data['name'],
      id: doc.id,
      email: data['email'],

      imageUrl: data['imageLink'],
      joinedEvents: List<String>.from(data['joinedEvents'] ??
          []), // Initialize joinedEvents list from Firestore data

      isAuthorized: data['isAuthorized'] ?? false,
    );
  }
}
