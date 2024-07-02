import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:student_welbeing/models/event_model.dart';
import 'package:student_welbeing/screens/Event/gallery.dart';
import 'package:student_welbeing/screens/GroupsAndChat/createSubgroup.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';

import '../../constants.dart';
import '../../provider/event_provider.dart';
import '../../utils/SizeConfig.dart';
import '../../widget_builders/generateRouteBuilder.dart';
import '../GroupsAndChat/invitations.dart';
import '../GroupsAndChat/listSubgroups.dart';
import 'ParticipantsPage.dart';
import '../../groupchat/group_chatPage.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event; // Event object passed from the home page
  final bool createdByUser;
  
  EventDetailsScreen({required this.event, required this.createdByUser});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late DateTime _dateTime = DateTime.now();
  late TextEditingController _dateTimeController;
  bool _userJoinedEvent = false;
  bool _isAdmin = false;

  late String mainimageurl = '';

  @override
  void initState() {
    super.initState();
    loadimage();
    // Initialize the TextEditingController
    _dateTimeController = TextEditingController();
    // Set the initial value for the date and time controller
    _dateTimeController.text =
        DateFormat('yyyy-MM-dd HH:mm').format(widget.event.dateTime);

    _checkIfUserJoinedEvent();
    _checkIfUserisAdmin();
  }

  void loadimage() async {
    mainimageurl = await widget.event.mainImageUrl!;
    setState(() {});
  }

  Future<bool> isUserParticipant(String eventId, String userEmail) async {
    try {
      // Reference to the event document
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (eventSnapshot.exists) {
        // Get the participants list from the event document
        List<String> participants =
            List<String>.from(eventSnapshot.get('participants') ?? []);

        // Check if the user's ID exists in the participants list
        return participants.contains(userEmail);
      } else {
        // Event document does not exist
        return false;
      }
    } catch (e) {
      print('Error checking user participation: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? currentUserEmail = user!.email;

    final width = SizeConfig.screenWidth;
    final height = SizeConfig.screenHeight;
    // ignore: unused_local_variable
    EventProvider eventProvider = Provider.of<EventProvider>(context);
    String formattedDate =
        DateFormat('dd MMMM, yyyy').format(widget.event.dateTime);
    String time = DateFormat('hh:mm a').format(widget.event.dateTime);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Event details',
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
        actions: [
          IconButton(
            icon: Icon(Clarity.notification_line),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InvitationsScreen(
                          curUserEmail: currentUserEmail,
                        ))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                // Event Image
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: mainimageurl.isNotEmpty
                      ? Image.network(mainimageurl)
                      : Image.asset(
                          'assets/images/img.png',
                        ), // Placeholder if image url is empty
                ),
              ),
              SizedBox(height: height * 0.02),
              // Event Title
              GradientText(
                widget.event.title,
                style: TextStyle(
                  fontSize: width * 0.08,
                ),
                colors: [
                  Colors.blue,
                  Colors.red,
                  Colors.teal,
                ],
              ),
              Text(
                'Hosted By - ' + widget.event.hostName,
                style: kTitletextstyle,
              ),
              Divider(
                height: width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Clarity.calendar_line,
                    size: width * 0.08,
                  ),
                  SizedBox(
                    width: width * 0.08,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $formattedDate',
                        style: kTitletextstyle.copyWith(color: Colors.black),
                      ),
                      Text(
                        'Time: $time',
                        style: kTitletextstyle.copyWith(
                            color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              ),
              Divider(
                height: width * 0.1,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Bootstrap.geo,
                    size: width * 0.08,
                  ),
                  SizedBox(
                    width: width * 0.08,
                  ),
                  Flexible(
                    child: Text(
                      'Location:\n' + widget.event.location,
                      style: kTitletextstyle.copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
              Divider(
                height: width * 0.1,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    HeroIcons.bars_3_bottom_left,
                    size: width * 0.08,
                  ),
                  SizedBox(
                    width: width * 0.08,
                  ),
                  Flexible(
                    child: Text(
                      'About Event: \n' + widget.event.description,
                      style: kTitletextstyle,
                    ),
                  ),
                ],
              ),

              Divider(
                height: width * 0.1,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Clarity.user_line,
                    size: width * 0.08,
                  ),
                  SizedBox(
                    width: width * 0.08,
                  ),
                  Flexible(
                    child: Text(
                      'Created By: \n' +
                          'Name : ' +
                          widget.event.createdby,
                      style: kTitletextstyle,
                    ),
                  ),
                ],
              ),
              Divider(
                height: width * 0.1,
              ),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.4,
                    height: width * 0.15,
                    child: ElevatedButton(
                        child: Text('Participants',
                            style: ksubTextstyle.copyWith(
                                color: Colors.white, fontSize: width * 0.045)),
                        onPressed: () => Navigator.push(
                            context,
                            generatePageRouteBuilder(
                              ParticipantsPage(
                                eventId: widget.event.id,
                              ),
                            )),
                        style: keventbuttonstyle(
                            backgroundColor: Color(0xffF1C40F),
                            foregroundColor: Colors.white,
                            shadowColor: Color(0xffF1C40F))),
                  ),
                  Spacer(),
                  SizedBox(
                    width: width * 0.4,
                    height: width * 0.15,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (await isUserParticipant(
                              widget.event.id, currentUserEmail!)) {
                            Navigator.push(
                              context,
                              generatePageRouteBuilder(
                                GroupChatPage(
                                  eventId: widget.event.id,
                                  curUserEmail: currentUserEmail,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Join Event to access event group chat'),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Flexible(
                              child: Text('Event Chat',
                                  style: ksubTextstyle.copyWith(
                                      color: Colors.white,
                                      fontSize: width * 0.05)),
                            ),
                          ],
                        ),
                        style: keventbuttonstyle(
                            backgroundColor: Color(0xffAED6F1),
                            foregroundColor: Colors.white,
                            shadowColor: Color(0xffAED6F1))),
                  )
                ],
              ),
              Divider(
                height: width * 0.1,
              ),
              Row(
                children: [
                  SizedBox(
                    width: width * 0.4,
                    height: width * 0.15,
                    child: ElevatedButton(
                      child: Text('SubGroups',
                          style: ksubTextstyle.copyWith(
                              color: Colors.white, fontSize: width * 0.045)),
                      onPressed: () async {
                        if (await isUserParticipant(
                            widget.event.id, currentUserEmail!)) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      SubgroupList(
                                eventId: widget.event.id,
                              ),
                              transitionDuration: Duration(milliseconds: 200),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Join event to view sub groups'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8fbc8f),
                        foregroundColor: Colors.white,
                        shadowColor: Color(0xff8fbc8f),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.03),
                          side: BorderSide(color: Colors.black, width: 1),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: width * 0.4,
                    height: width * 0.15,
                    child: ElevatedButton(
                      style: keventbuttonstyle(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.blue),
                      onPressed: () => Navigator.push(
                        context,
                        generatePageRouteBuilder(
                          EventGallery(
                              createdByUser: widget.createdByUser,
                              eventid: widget.event.id),
                        ),
                      ),
                      child: Text("Gallery",
                          style: ksubTextstyle.copyWith(
                              color: Colors.white, fontSize: width * 0.05)),
                    ),
                  ),
                ],
              ),

              Divider(
                height: width * 0.1,
              ),
              SizedBox(
                height: width * 0.15,
                child: ElevatedButton(
                    child: Text('Create SubGroups',
                        style: ksubTextstyle.copyWith(
                            color: Colors.white, fontSize: width * 0.045)),
                    onPressed: () async {
                      if (await isUserParticipant(
                          widget.event.id, currentUserEmail!)) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CreateSubGroups(
                              eventId: widget.event.id,
                            ),
                            transitionDuration: Duration(milliseconds: 200),
                            transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) =>
                                FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Join event to create sub groups'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2ecc71),
                      foregroundColor: Colors.white,
                      shadowColor: Color(0xff2ecc71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.03),
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                      elevation: 5,
                    )),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.02, vertical: width * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /*     Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ ' + event.ticketPrice.toString(),
                    style: kHeadText,
                  ),
                  Text(
                    'Ticket Price',
                    style: kDateTextStyle,
                  ),
                ],
              ),*/
              if (widget.createdByUser)
                Text(
                  'You are the Host of this Event',
                  style: kDateTextStyle.copyWith(
                    fontSize: width * 0.04,
                  ),
                ),
              if (widget.createdByUser) Spacer(),
              if (widget.createdByUser)
                Material(
                  color: Theme.of(context).primaryColorLight,
                  elevation: 4, // Set the desired elevation here
                  shape: CircleBorder(),
                  child: IconButton(
                    onPressed: () => _editEvent(context),
                    icon: Icon(
                      Icons.edit,
                    ),
                  ),
                ),
              if (widget.createdByUser) Spacer(),
              if (widget.createdByUser || _isAdmin)
                Material(
                  color: Colors.red[400],

                  elevation: 4, // Set the desired elevation here
                  shape: CircleBorder(),
                  child: IconButton(
                    onPressed: () => _deleteEvent(context),
                    icon: Icon(
                      color: Colors.white,
                      Icons.delete_outline,
                    ),
                  ),
                ),
              Spacer(),
              if (!_userJoinedEvent && !widget.createdByUser)
                ElevatedButton(
                  onPressed: () => _joinEvent(context),
                  child: Center(
                    child: Row(
                      children: [
                        Text(
                          'JOIN NOW',
                          style: TextStyle(
                              fontFamily: 'ABC Diatype',
                              fontWeight: FontWeight.w600,
                              fontSize: width * 0.05,
                              color: Colors.black),
                        ),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        Image.asset(
                          'assets/icons/ticket2.png',
                          height: height * 0.05,
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF625C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21.0),
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    elevation: 5,
                  ),
                ),
              if (_userJoinedEvent || widget.createdByUser)
                Flexible(
                  flex: 12,
                  child: Text(
                    _userJoinedEvent && !widget.createdByUser
                        ? 'You have already joined this event.'
                        : '',
                    style: kDateTextStyle.copyWith(
                      fontSize: width * 0.035,
                    ),
                  ),
                ),
              Spacer(),
              if (_userJoinedEvent && !widget.createdByUser)
                ElevatedButton(
                  onPressed: () => _leaveEvent(context),
                  child: Text(
                    'Leave Event',
                    style: TextStyle(
                      fontFamily: 'ABC Diatype',
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.03,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.redAccent, // Change to desired color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21.0),
                    ),
                    elevation: 5,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Function to handle joining the event
  void _joinEvent(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? userEmail = user?.email;
      // Get a reference to the event document in Firestore
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      // Add the current user to the participants list
      await eventRef.update({
        'participants': FieldValue.arrayUnion([userEmail])
      });
      // Add the event ID to the joinedEvents list in the user model
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .update({
        'joinedEvents': FieldValue.arrayUnion([widget.event.id]),
      });

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have joined the event successfully!'),
        ),
      );
      setState(() {
        _userJoinedEvent = true;
      });
    } catch (error) {
      // Show an error message if joining the event fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join the event. Please try again.'),
        ),
      );
    }
  }

  void _editEvent(BuildContext context) async {
    try {
      // Get a reference to the event document in Firestore
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      // Open a dialog to allow the user to edit the event details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit Event'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: widget.event.title,
                    decoration: InputDecoration(labelText: 'Event Title'),
                    onChanged: (value) {
                      // Update the event title
                      widget.event.title = value;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.event.description,
                    decoration: InputDecoration(labelText: 'Event Description'),
                    onChanged: (value) {
                      // Update the event description
                      widget.event.description = value;
                    },
                  ),
                  TextFormField(
                    initialValue: widget.event.location,
                    decoration: InputDecoration(labelText: 'Event Location'),
                    onChanged: (value) {
                      // Update the event location
                      widget.event.location = value;
                    },
                  ),
                  TextFormField(
                    controller: _dateTimeController,
                    readOnly: true,
                    onTap: _selectDateTime,
                    decoration: InputDecoration(
                      suffixIcon: Icon(Clarity.calendar_line),
                      labelText: 'Date and Time',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Update the event details in Firestore
                  await eventRef.update({
                    'title': widget.event.title,
                    'description': widget.event.description,
                    'location': widget.event.location,
                    'dateTime': _dateTime,
                  });
                  setState(() {});

                  // Show a success message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event updated successfully!'),
                    ),
                  );

                  // Close the dialog
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Show an error message if editing the event fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to edit the event. Please try again.'),
        ),
      );
    }
  }

  void _deleteEvent(BuildContext context) async {
    try {
      // Get a reference to the event document in Firestore
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      // Show a confirmation dialog before deleting the event
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Event'),
            content: Text('Are you sure you want to delete this event?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Close the dialog without deleting the event
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Delete the event from Firestore
                  await eventRef.delete();

                  // Show a success message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event deleted successfully!'),
                    ),
                  );

                  // Close the dialog
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Show an error message if deleting the event fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete the event. Please try again.'),
        ),
      );
    }
  }

// Check if user has joinied the event

  Future<void> _checkIfUserJoinedEvent() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.event.id)
          .get();
      dynamic data = eventDoc.data();
      if (data != null && data['participants'] != null) {
        List<dynamic> participants = List.from(data['participants']);
        if (participants.contains(user.email)) {
          setState(() {
            _userJoinedEvent = true;
          });
        }
      }
    }
  }

  Future<void> _checkIfUserisAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();
      dynamic data = userDoc.data();
      if (data['isAdmin'] == true) {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  // Date and teim picker

  Future<void> _selectDateTime() async {
    DateTime? dateTime = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3652)),
    );

    if (dateTime != null) {
      TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );

      if (timeOfDay != null) {
        setState(() {
          _dateTime = DateTime(
            dateTime.year,
            dateTime.month,
            dateTime.day,
            timeOfDay.hour,
            timeOfDay.minute,
          );

          // Update the value of the TextEditingController with the selected date and time
          _dateTimeController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(_dateTime);
        });
      }
    }
  }

  void _leaveEvent(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? userEmail = user?.email;

      // Get a reference to the event document in Firestore
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      // Remove the current user from the participants list
      await eventRef.update({
        'participants': FieldValue.arrayRemove([userEmail])
      });

      // Remove the event ID from the joinedEvents list in the user document

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .update({
        'joinedEvents': FieldValue.arrayRemove([widget.event.id]),
      });

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have left the event successfully!'),
        ),
      );

      setState(() {
        _userJoinedEvent = false;
      });
    } catch (error) {
      // Show an error message if leaving the event fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave the event. Please try again.'),
        ),
      );
    }
  }
}
