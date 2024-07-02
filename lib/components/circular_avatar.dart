import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';

class MyCircularAvatar extends StatelessWidget {
  final double radius;

  MyCircularAvatar({
    Key? key,
    required this.radius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthService _auth = AuthService();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.getCurrentUser()!.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while fetching data
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        String profileImageUrl;

        // Check if the 'imageLink' field exists in the user's data
        Map<String, dynamic>? userData =
            snapshot.data!.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('imageLink')) {
         if(userData['imageLink']!=null)
         { profileImageUrl = userData['imageLink'];}
         else{
           profileImageUrl =
              'https://static-00.iconduck.com/assets.00/user-icon-2048x2048-ihoxz4vq.png';
         }
        } else {
          // Set a default profile image URL if 'imageLink' does not exist
          profileImageUrl =
              'https://static-00.iconduck.com/assets.00/user-icon-2048x2048-ihoxz4vq.png';
        }

        return CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(profileImageUrl),
        );
      },
    );
  }
}
