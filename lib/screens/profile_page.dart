import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_welbeing/components/circular_avatar.dart';
import 'package:student_welbeing/components/myButton.dart';
import 'package:student_welbeing/components/mytextfield.dart';
import 'package:student_welbeing/components/mytextfield1.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';
import 'package:student_welbeing/services/data_update/user_service.dart';

import '../components/navbar.dart';
import '../utils/SizeConfig.dart';
import '../utils/utils.dart';
import 'Login_Register/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _bio=TextEditingController();
  Uint8List? _image;
  late String userName = '';
  String _userEmail = ''; // Initialize _userEmail variable
  @override
  void initState() {
   
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final AuthService authService = AuthService();

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);

    if (img != null) {
      // Upload image to storage
      String imageUrl =
          await UserService().uploadImageToStorage(_userEmail, img);

      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('Users').doc(_userEmail).set({
        'imageLink': imageUrl,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();
      //var userName = authService.getCurrentUser()?.displayName;
      final user = authService.getCurrentUser();
      setState(() {
        //userName = userName!;
        _userEmail = user!.email??'';
      });
       DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
       .collection('Users')
       .doc(_userEmail)
       .get();

    if (docSnapshot.exists) {
      // Cast the bio to String
      _bio.text = docSnapshot.get('bio') as String;
    } else {
      // Handle the case where the document does not exist
      print("Document does not exist.");
    }
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

  void _showEditNameDialog(BuildContext context) {
    String updatedName = userName; // Initialize with current name

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            onChanged: (value) {
              updatedName =
                  value; // Update the updatedName variable as user types
            },
            controller: TextEditingController(
                text: userName), // Initialize with current name
            decoration: InputDecoration(
              hintText: 'Enter your name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (updatedName.isNotEmpty) {
                  await _saveUpdatedName(updatedName);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Name cannot be empty!'),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUpdatedName(String updatedName) async {
    setState(() {
      userName = updatedName;
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_userEmail)
        .update({'name': updatedName});
  }

  @override
  Widget build(BuildContext context) {
    final width = SizeConfig.screenWidth;

    final fontsize = width * 0.05;

    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Are you sure you want to exit?'),
                actions: [
                  TextButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Yes, exit'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });
        return value == true;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 4,
          onItemTapped: (int value) {},
        ),
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Row(
            children: [
              SizedBox(
                width: SizeConfig.screenWidth * 0.04,
              ),
              Text(
                "Profile",
                style: kTitletextstyle.copyWith(
                    fontSize: SizeConfig.screenWidth * 0.05,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
             // height: SizeConfig.screenHeight / 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  Center(
                    child: Stack(
                      children: [
                        MyCircularAvatar(radius: 64),
                        Positioned(
                          bottom: -10,
                          left: 80,
                          child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: width * 0.2,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(_userEmail)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show a loading indicator while fetching data
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      // Get the username from the snapshot
                      String? userName = snapshot.data?.get('name');

                      return Container(
                        width: width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0xffEEEEEE),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Container(
                            child: Row(
                              children: [
                                Icon(Icons.person_outlined),
                                SizedBox(
                                  width: width * 0.025,
                                ),
                                Text(
                                  'Name: ${userName ?? ''}',
                                  style: TextStyle(
                                      fontSize: width * 0.04,
                                      fontWeight: FontWeight.w600),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditNameDialog(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: width * 0.05,
                  ),
                  Container(
                    width: width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffEEEEEE),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      child: Row(
                        children: [
                          Icon(Clarity.email_line),
                          SizedBox(
                            width: width * 0.025,
                          ),
                          Flexible(
                            child: Text(
                              '$_userEmail',
                              style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                 MyTextField1(
                
                  controller: _bio,
                   hint: 'Describe yourself', 
                   obscure: false,
                    selection: false,
                     preIcon: Icons.biotech),
    SizedBox(
      height: 10,
    ),
                  //Spacer(),
                   SizedBox(
                    height: width * 0.12,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
        .collection('Users')
        .doc(_userEmail)
        .update({'bio': _bio.text});
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(fontSize: 24),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: width * 0.12,
                    child: ElevatedButton(
                      onPressed: () async {
                        await logout(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Logout',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(
                            width: width * 0.05,
                          ),
                          Icon(Icons.login_rounded)
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final _auth = AuthService();
    userName = '';

    await _auth.signOut(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
