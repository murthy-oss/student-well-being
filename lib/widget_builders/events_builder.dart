import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:student_welbeing/screens/Event/pastEventDetails.dart';
import '../constants.dart';
import '../models/event_model.dart';
import '../screens/Event/event_detail.dart';

SizedBox event_builder(BuildContext context, List<Event> events,
    String userEmail, bool calledfrom) {
  final Size screenSize = MediaQuery.of(context).size;
  final width = screenSize.width;
  final height = screenSize.height;
  // Define a list of colors for the list tile headings
  List<Color?> textColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple[300],
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.deepOrange,
    Colors.indigo,
    Colors.lightGreen,
  ];

  events.sort((a, b) => a.dateTime.compareTo(b.dateTime));

  return SizedBox(
    height: height * 0.9,
    width: width,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: events.length,
      itemBuilder: (context, index) {
        Event event = events[index];
        // Get the color for the current list tile based on its index
        Color? textColor = textColors[index % textColors.length];

        // Format the date using DateFormat with month name pattern
        String formattedDate =
            DateFormat('dd MMM, yyyy').format(event.dateTime);

        bool createdByCurrentUser = event.creater_email == userEmail;

        return GestureDetector(
          onTap: () {
            if (calledfrom) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      EventDetailsScreen(
                    event: event,
                    createdByUser: createdByCurrentUser,
                  ),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PastEventScreen(
                    event: event,
                    createdByUser: createdByCurrentUser,
                  ),
                  transitionDuration: Duration(milliseconds: 200),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
              );
            }
          },
          child: ListTile(
            title: Stack(children: [
              Card(
                color: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 3,

                /* shadowColor: textColor,
                surfaceTintColor: textColor,*/
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 40, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Clarity.star_line,
                            size: width * 0.05,
                            color: textColor,
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Flexible(
                            flex: 6,
                            child: Text(
                              event.title.toString(),
                              style: kTitletextstyle.copyWith(
                                  color: Colors.black, fontSize: width * 0.05),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    Divider(
                      indent: 5,
                      endIndent: 5,
                      color: textColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Row(
                        children: [
                          /*SizedBox(
                                  width: SizeConfig.screenWidth * 0.075,
                                ),*/
                          Icon(
                            Clarity.date_line,
                            size: width * 0.05,
                          ),
                          SizedBox(
                            width: width * 0.018,
                          ),
                          Text(
                            formattedDate,
                            style: kDateTextStyle.copyWith(
                                fontSize: width * 0.03,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    /*  Divider(
                      indent: 5,
                      endIndent: 5,
                    ),*/
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            HeroIcons.bars_3_bottom_left,
                            size: width * 0.045,
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Flexible(
                            child: Text(
                              'Description : ' + event.description.toString(),
                              style: ksubTextstyle.copyWith(
                                  fontSize: width * 0.03, color: Colors.black),
                              maxLines:
                                  6, // Set the maximum number of lines to display
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: "Event Description",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Bootstrap.geo,
                            size: width * 0.045,
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          Flexible(
                            child: Text(
                              event.location.toString(),
                              style: ksubTextstyle.copyWith(
                                  fontSize: width * 0.03, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /*
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                      child: Row(
                        children: [
                          Icon(Clarity.dollar_bill_line),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '₹' + event.ticketPrice.toString() + " /-",
                            style: ksubTextstyle,
                          ),
                        ],
                      ),
                    )
              */
                  ],
                ),
              ),
              Positioned(
                  top: 3,
                  right: 3,
                  child: Container(
                      decoration: BoxDecoration(
                        color: event.mode == 'Physical'
                            ? Colors.green
                            : Colors.blue,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            Icon(
                              Clarity.dot_circle_line,
                              color: Colors.white,
                              size: width * 0.03,
                            ),
                            Text(
                              event.mode.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'ABC Diatype',
                                  color: Colors.white,
                                  fontSize: width * 0.025),
                            ),
                          ],
                        ),
                      )))
            ]),
          ),
        );
      },
    ),
  );
}
