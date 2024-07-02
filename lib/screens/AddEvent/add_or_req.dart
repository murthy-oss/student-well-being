/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/models/event_model.dart';
import 'package:student_welbeing/screens/home_page.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';
import '../components/myButton.dart';
import '../components/navbar.dart';
import '../provider/user_provider.dart';
import '../services/authentication/auth_service.dart';
import '../services/data_update/event_service.dart';
import 'add_event_page.dart';

class CombinedScreen extends StatefulWidget {
  @override
  _CombinedScreenState createState() => _CombinedScreenState();
}

class _CombinedScreenState extends State<CombinedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  final CollectionReference userRequests =
      FirebaseFirestore.instance.collection('user_requests');
  late bool isAuthorized;
  late String _hostName;
  late String _title;
  late DateTime _dateTime = DateTime.now();
  late String _location;
  late String _description;
  late double _ticketPrice;

  late List<String> _coHostNames = [];

  late TextEditingController _dateTimeController;

  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController
    _dateTimeController = TextEditingController();
    _initializeAuthorization();
  }

  void _initializeAuthorization() async {
    final AuthService _authService = AuthService();
    final User? currentUser = await _authService.getCurrentUserUID();

    if (currentUser != null) {
      String uid = currentUser.uid;

      try {
        DocumentSnapshot snapshot =
            await FirebaseFirestore.instance.collection("Users").doc(uid).get();

        if (snapshot.exists && snapshot.data() is Map<String, dynamic>) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data.containsKey('isAuthorized')) {
            bool isAuthorizedbyadmin = data['isAuthorized'];

            Provider.of<UserProvider>(context, listen: false)
                .updateAuthorization(isAuthorizedbyadmin);
            setState(() {
              // Update the local variable with the value from the database
              isAuthorized = isAuthorizedbyadmin;
            });
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void dispose() {
    // Dispose the TextEditingController
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAuthorized = false;
    isAuthorized = Provider.of<UserProvider>(context).isAuthorized;

    return ChangeNotifierProvider(
      create: (_) => UserProvider(), // Wrap with ChangeNotifierProvider
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 1,
          onItemTapped: (int value) {},
        ),
        backgroundColor: ScaffoldColor,
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          title: Text(isAuthorized ? 'Add Event' : 'Request Admin'),
        ),
        body: StreamBuilder<bool>(
          stream: Provider.of<UserProvider>(context).authorizationStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator if data is not yet available
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if there's an error
            } else {
              // Check if isAuthorized status has changed
              isAuthorized = snapshot.data ?? false;
              return isAuthorized
                  ? buildAddEventUI(context)
                  : buildRequestAdminUI();
            }
          },
        ),
      ),
    );
  }

  Widget buildAddEventUI(BuildContext context) {
    final width = SizeConfig.screenWidth;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the snapshot
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Show an error message if there's an error with the snapshot
          return Text('Error: ${snapshot.error}');
        } else {
          // Extract the isAuthorized value from the snapshot data
          final bool isAuthorized = snapshot.data?['isAuthorized'] ?? false;

          // Check if the user is authorized
          if (isAuthorized) {
            // If user is authorized, build the add event UI
            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Container(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            _buildInputField(
                              labelText: 'Event Title',
                              initialValue: '',
                              onSaved: (value) => _title = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter event title';
                                }
                                return null;
                              },
                              icon: Icon(Clarity.event_outline_badged),
                            ),
                            SizedBox(height: width * 0.05),
                            _buildInputField(
                              labelText: 'Host Name',
                              initialValue: '',
                              onSaved: (value) => _hostName = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter host name';
                                }
                                return null;
                              },
                              icon: Icon(Icons.person_outline_rounded),
                            ),
                            SizedBox(height: width * 0.05),
                            _buildInputField(
                              labelText: 'Location',
                              initialValue: '',
                              onSaved: (value) => _location = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter location';
                                }
                                return null;
                              },
                              icon: Icon(
                                Bootstrap.geo,
                              ),
                            ),
                            SizedBox(height: width * 0.05),
                            _buildInputField(
                              labelText: 'Description',
                              initialValue: '',
                              maxLines: null,
                              onSaved: (value) => _description = value!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                              icon: Icon(
                                HeroIcons.bars_3_bottom_left,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildInputField(
                              labelText: 'Ticket Price',
                              initialValue: '',
                              onSaved: (value) =>
                                  _ticketPrice = double.parse(value!),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter ticket price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              icon: Icon(Clarity.dollar_bill_line),
                            ),
                            SizedBox(height: width * 0.05),
                            _buildInputField(
                              labelText: 'Co-Host Names (Optional)',
                              initialValue: '',
                              onSaved: (value) {
                                if (value != null && value.isNotEmpty) {
                                  _coHostNames = value
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();
                                }
                              },
                              icon: Icon(Icons.group_outlined),
                            ),
                            SizedBox(height: width * 0.05),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(0xffEEEEEE),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 5,
                                ),
                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select Date and Time';
                                    }

                                    return null;
                                  },
                                  readOnly: true,
                                  onTap: _selectDateTime,
                                  controller:
                                      _dateTimeController, // Use the TextEditingController here
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    suffixIcon: Icon(Clarity.calendar_line),
                                    labelText: 'Date and Time',
                                    labelStyle: TextStyle(
                                      fontFamily: 'ABC Diatype',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.05),
                          ],
                        ),
                      ),
                      MyButton(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final event = Event(
                              hostName: _hostName,
                              dateTime:
                                  _dateTime, // Use the combined date and time
                              location: _location,
                              description: _description,
                              ticketPrice: _ticketPrice,

                              coHostNames: _coHostNames,
                              title: _title,
                              createdby: '',
                              creater_email: '',
                              id: '',
                            );
                            bool success =
                                await _eventService.addEvent(context, event);
                            _showEventCreationStatus(success);
                          }
                        },
                        text: 'Save Event',
                        color: Color(0xff76986e),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // If user is not authorized, build the request admin UI
            return buildRequestAdminUI();
          }
        }
      },
    );
  }

  Widget buildRequestAdminUI() {
    return Center(
      child: StreamBuilder<DocumentSnapshot>(
        stream: userRequests
            .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator if snapshot is still loading
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Show error message if there's an error
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.exists) {
            // Show message indicating that the request is pending and a cancel button
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You have already requested admin approval. Waiting for approval.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20), // Add some spacing
                MyButton(
                  onTap: cancelRequest,
                  text: 'Cancel Request',
                  color: Colors.red, // Choose a color for the cancel button
                ),
              ],
            );
          } else {
            // Show button to request admin if no request has been sent
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You are not authorized to post events.\nRequest Admin to continue",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20), // Add some spacing
                MyButton(
                  onTap: requestAdmin,
                  text: 'Request Admin',
                  color: Colors.blue,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildInputField({
    required String labelText,
    required String initialValue,
    required Icon icon,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(0xffEEEEEE),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        child: TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: icon,
            labelStyle:
                TextStyle(fontFamily: 'ABC Diatype', fontWeight: FontWeight.w600),
            labelText: labelText,
          ),
          initialValue: initialValue,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          onSaved: onSaved,
          maxLines: maxLines, // Set the maxLines property here
        ),
      ),
    );
  }

  // Event creation Status

  void _showEventCreationStatus(bool success) {
    print("Event creation success: $success");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: success ? Text('Success') : Text('Error'),
          content: success
              ? Text('Event created successfully!')
              : Text('Error creating event. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          HomePage())); // Pop the current route
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

// Date and Time picker

  Future<void> _selectDateTime() async {
    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3652)),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      isForce2Digits: true,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(Tween(begin: 0, end: 1)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        // Disable 25th Feb 2023
        return dateTime != DateTime(2023, 2, 25);
      },
    );

    if (dateTime != null) {
      setState(
        () {
          _dateTime = dateTime;

          // Update the value of the TextEditingController with the selected date and time
          _dateTimeController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(_dateTime);
        },
      );
    }
  }

  // Function to handle the request admin button tap
  void requestAdmin() async {
    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Create a document in the admin_requests collection with the user's UID
    await userRequests.doc(uid).set({
      'uid': uid,
      // Add any other relevant information here
    });

    // Show a message or perform any other action after the request is sent
    print('Admin request sent successfully!');
  }

  void cancelRequest() async {
    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Delete the document from the user_requests collection
    await userRequests.doc(uid).delete();

    // Show a message or perform any other action after the request is cancelled
    print('Admin request cancelled successfully!');
  }
}

class MyButton extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color color;

  const MyButton({
    required this.onTap,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onTap(),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // Adjust as needed
        height: MediaQuery.of(context).size.width * 0.13,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontFamily: 'ABC Diatype', fontWeight: FontWeight.w600, fontSize: 30),
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          elevation: 4),
    );
  }
}
*/
