import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../authentication/auth_service.dart';

final _auth = AuthService();

String? email = _auth.getCurrentUser()?.email;

final FirebaseStorage _storage = FirebaseStorage.instance;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String userEmail;

  Future<void> addUserToFirestore(String uid, String email, String name, String? photoURL) async {
    try {
      await _firestore.collection("Users").doc(email).set(
        {'uid': uid,
         'email': email,
         'name': name, 
         'imageLink':photoURL??'https://static-00.iconduck.com/assets.00/user-icon-2048x2048-ihoxz4vq.png',
         'joinedEvents': []},
      );
    } catch (e) {
      print("Error adding user to Firestore: $e");
      throw Exception("Failed to add user to Firestore");
    }
  }

  Future<String> getCurrentUserName() async {
    try {
      // Fetch user information from Firestore
      DocumentSnapshot userSnapshot =
          await _firestore.collection("Users").doc(email).get();

      String userName = userSnapshot['name'] ?? 'Unknown';

      return userName;
    } catch (e) {
      print("Error getting current user's name: $e");
      return 'Unknown';
    }
  }

/*  Future<String> getCurrentUserEmail(String uid) async {
    try {
      // Fetch user information from Firestore
      DocumentSnapshot userSnapshot =
          await _firestore.collection("Users").doc(uid).get();

      userEmail = userSnapshot['email'] ?? 'Unknown';

      return userEmail;
    } catch (e) {
      print("Error getting current user's email: $e");
      return 'Unknown';
    }
  }*/

  // Upload Image to Storage

  Future<String> uploadImageToStorage(String userId, Uint8List file) async {
    try {
      String fileName =
          'profileImage_$userId'; // Unique file name for each user
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image to storage: $e");
      throw Exception("Failed to upload image to storage");
    }
  }

  Stream<DocumentSnapshot> getUserDocumentStream(String userEmail) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .snapshots();
  }

  // Sava Data to storage
  Future<String> saveData({
    required String name,
    Uint8List? file,
    required String userEmail,
  }) async {
    String resp = "Some Error Occurred";
    try {
      if (file != null) {
        // Upload image to storage
        String imageUrl = await uploadImageToStorage(userEmail, file);

        // Update user data in Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .set({
          'name': name,
          'imageLink': imageUrl,
        }, SetOptions(merge: true));

        resp = 'success';
      } else if (file == null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .set({
          'name': name,
        }, SetOptions(merge: true));
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
