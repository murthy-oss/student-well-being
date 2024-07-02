import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:student_welbeing/screens/AddEvent/add_or_req.dart';
import 'package:student_welbeing/screens/Home/home_page.dart';
import 'package:student_welbeing/screens/chatpage/listofuserstochat.dart';

import '../screens/Event/joined_events_page.dart';
import '../screens/Event/my_events.dart';
import '../screens/profile_page.dart';
import '../screens/AddEvent/req_add.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late bool isAuthorized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      fixedColor: Colors.blueAccent,
      selectedLabelStyle: TextStyle(
          color: Colors.blueAccent,
          fontFamily: 'ABC Diatype',
          fontWeight: FontWeight.bold),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      items: [
        _buildNavBarItem(Clarity.home_line, HeroIcons.home, "Home", 0),
        _buildNavBarItem(
            Clarity.add_line, Clarity.add_text_line, "Add Event", 1),
        _buildNavBarItem(
            Clarity.chat_bubble_outline_badged, Clarity.chat_bubble_outline_badged, "Chats", 2),
        _buildNavBarItem(Clarity.star_line, Clarity.star_solid, "My Events", 3),
        _buildNavBarItem(Clarity.user_line, Clarity.user_solid, "Profile", 4),
      ],
      currentIndex: widget.selectedIndex,
      onTap: (index) {
        if (index != widget.selectedIndex) {
          widget.onItemTapped(index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomePage(),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ReqORAdd(),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
              break;

            case 2:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ListOfUsersToChat(),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MyEvents(),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProfilePage(),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
              break;
          }
        }
      },
    );
  }

  BottomNavigationBarItem _buildNavBarItem(
      IconData iconData, IconData activeIconData, String label, int index) {
    return BottomNavigationBarItem(
        icon: Icon(
          iconData,
          size: 27,
          color:
              widget.selectedIndex == index ? Colors.blueAccent : Colors.black,
        ),
        activeIcon: Icon(
          activeIconData,
          size: 32,
          color: Colors.blueAccent,
        ),
        label: label,
        tooltip: label);
  }

  Future<bool> _isAuth(String userID) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot senderSnapshot =
        await _firestore.collection("Users").doc(userID).get();

    if (senderSnapshot.exists &&
        senderSnapshot.data() is Map<String, dynamic>) {
      Map<String, dynamic> data = senderSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('isAuthorized')) {
        return data['isAuthorized'];
      }
    }

    return false;
  }
}
