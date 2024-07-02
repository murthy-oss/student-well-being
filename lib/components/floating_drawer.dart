import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_welbeing/constants.dart';

import '../provider/floating_window_provider.dart';
import 'circular_avatar.dart';

class FloatingDrawer extends StatelessWidget {
  final String userEmail;

  final Function() onProfileTap;
/*
  final Function() onSettingsTap;
*/
  final Function() onInviteFriendsTap;
  final Function() onSupportTap;
  final Function() onLogoutTap;

  const FloatingDrawer({
    Key? key,
    required this.onProfileTap,
/*
    required this.onSettingsTap,
*/
    required this.onInviteFriendsTap,
    required this.onSupportTap,
    required this.onLogoutTap,
    required this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final floatingDrawerProvider = Provider.of<FloatingWindowProvider>(context);
    final Size screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return floatingDrawerProvider.isFloatingDrawerOpen
        ? Positioned(
            top: -3,
            right: width * 0.42,
            child: GestureDetector(
              onTap: () {
                Provider.of<FloatingWindowProvider>(context, listen: false)
                    .toggleFloatingDrawer();
              },
              child: Container(
                color: Colors.transparent,
                width: width * 0.6,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(userEmail)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Show a loading indicator while fetching data
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            String? userName = snapshot.data?.get('name');
                            return Column(
                              children: [
                                MyCircularAvatar(
                                  radius: 35,
                                ),
                                SizedBox(height: 10),
                                Text(userName ?? 'Guest',
                                    style: kTitletextstyle.copyWith(
                                        fontSize: width * 0.04)),
                                SizedBox(
                                  child: Text(userEmail,
                                      style:
                                          Theme.of(context).textTheme.titleSmall),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('View Profile'),
                        onTap: onProfileTap,
                      ),
                      Divider(height: 0),
                      /* ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: onSettingsTap,
                      ),*/
                      Divider(height: 0),
                      ListTile(
                        leading: Icon(Icons.group_add),
                        title: Text('Invite Friends'),
                        onTap: onInviteFriendsTap,
                      ),
                      Divider(height: 0),
                      ListTile(
                        leading: Icon(Icons.help),
                        title: Text('Support'),
                        onTap: onSupportTap,
                      ),
                      Divider(height: 0),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log Out'),
                        onTap: onLogoutTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }
}
