import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:student_welbeing/models/event_model.dart';
import 'package:uuid/uuid.dart';

import '../authentication/auth_service.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userEmail = '';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ignore: unused_element
  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();
/*
      String userName = await authService.getCurrentUserName();
*/
      final user = authService.getCurrentUser();

      userEmail = user?.email ?? '';
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

  Future<bool> addEvent(BuildContext context, Event event) async {
    final authService = AuthService();
    final userName =
        await authService.getCurrentUser()?.displayName; // Retrieve username
    final userEmail =
        await authService.getCurrentUser()!.email!; // Retrieve email (optional)
    try {
      // Convert DateTime to Timestamp for Firestore
      Timestamp timestamp = Timestamp.fromDate(event.dateTime);

      await _firestore.collection('events').add({
        'hostName': event.hostName,
        'createdby': userName,
        'creater_email': userEmail,
        'date': timestamp, // Save as Timestamp
        'title': event.title,
        'dateTime': timestamp, // Save combined date and time as Timestamp
        'location': event.location,
        'description': event.description,
/*
        'ticketPrice': event.ticketPrice,
*/
        'coHostNames': event.coHostNames,
        'mode': event.mode,
        'participants': [userEmail],
        'mainimage': event.mainImageUrl,
        'imageUrls': [],
      });
      return true;
    } catch (e) {
      // Handle error
      print('Error adding event: $e');
      // Display a more detailed error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error adding event: $e'),
      ));
      return false;
    }
  }

  Future<String> uploadImageToStorage(Uint8List file) async {
    try {
      final uuid = Uuid();
      String filename = uuid.v4();
      Reference ref = _storage.ref().child(filename);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image to storage: $e");
      throw Exception("Failed to upload image to storage");
    }
  }
}
