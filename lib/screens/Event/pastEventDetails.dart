import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../../constants.dart';
import '../../groupchat/group_chatPage.dart';
import '../../models/event_model.dart';
import '../../provider/event_provider.dart';
import '../../utils/SizeConfig.dart';
import '../../widget_builders/generateRouteBuilder.dart';
import '../GroupsAndChat/createSubgroup.dart';
import '../GroupsAndChat/invitations.dart';
import '../GroupsAndChat/listSubgroups.dart';
import 'ParticipantsPage.dart';
import 'gallery.dart';

class PastEventScreen extends StatefulWidget {
  final Event event; // Event object passed from the home page
  final bool createdByUser;
  const PastEventScreen(
      {super.key, required this.event, required this.createdByUser});

  @override
  State<PastEventScreen> createState() => _PastEventScreenState();
}

class _PastEventScreenState extends State<PastEventScreen> {
  late DateTime _dateTime = DateTime.now();
  late TextEditingController _dateTimeController;
  bool _userJoinedEvent = false;
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
    String currUserEmail = user!.email!;

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
                          curUserEmail: currUserEmail,
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
                          widget.event.createdby +
                          '\n' +
                          'Email : ' +
                          widget.event.creater_email,
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
                              widget.event.id, currUserEmail!)) {
                            Navigator.push(
                              context,
                              generatePageRouteBuilder(
                                GroupChatPage(
                                  eventId: widget.event.id,
                                  curUserEmail: currUserEmail,
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
                    height: width * 0.15,
                    child: ElevatedButton(
                        child: Text('Create SubGroups',
                            style: ksubTextstyle.copyWith(
                                color: Colors.white, fontSize: width * 0.045)),
                        onPressed: () async {
                          if (await isUserParticipant(
                              widget.event.id, currUserEmail!)) {
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
                                content:
                                    Text('Join event to create sub groups'),
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
                  Spacer(),
                  SizedBox(
                    height: width * 0.15,
                    child: ElevatedButton(
                      child: Text('SubGroups',
                          style: ksubTextstyle.copyWith(
                              color: Colors.white, fontSize: width * 0.045)),
                      onPressed: () async {
                        if (await isUserParticipant(
                            widget.event.id, currUserEmail)) {
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
                ],
              ),
              Divider(
                height: width * 0.1,
              ),
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
                  child: Text("Event Gallery",
                      style: ksubTextstyle.copyWith(
                          color: Colors.white, fontSize: width * 0.05)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
