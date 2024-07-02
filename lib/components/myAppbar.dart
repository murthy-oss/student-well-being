import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';

import '../provider/floating_window_provider.dart';
import '../utils/SizeConfig.dart';
import 'circular_avatar.dart';

AppBar MyAppBar(BuildContext context) {
  AuthService _auth = AuthService();

  final width = SizeConfig.screenWidth;
  final height = SizeConfig.screenHeight;
  return AppBar(
    backgroundColor: Colors.blueAccent,
    elevation: 0,
    title: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.getCurrentUser()!.email)
          .snapshots(),
      builder: (context, snapshot) {
        /*if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show a loading indicator while fetching data
        }*/
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        String? userName = snapshot.data?.get('name');
        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Provider.of<FloatingWindowProvider>(context, listen: false)
                        .toggleFloatingDrawer();
                  },
                  child: MyCircularAvatar(
                    radius: 20,
                  ),
                ),
                SizedBox(width: 5),
                Text(
                  'Hi ',
                  style: ksubTextstyle.copyWith(color: Colors.white),
                ),
                Container(
                  child: Text(
                    userName ?? 'Guest',
                    style: ksubTextstyle.copyWith(color: Colors.white),
                  ),
                ),
                Spacer(flex: 3),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Clarity.search_line,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
    centerTitle: true,
  );
}
