import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/models/event_model.dart';
import 'package:student_welbeing/screens/Login_Register/login_page.dart';
import 'package:student_welbeing/screens/profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/floating_drawer.dart';
import '../../components/myAppbar.dart';
import '../../components/navbar.dart';
import '../../services/authentication/auth_service.dart';
import '../../widget_builders/events_builder.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

void logout(BuildContext context) {
  final _auth = AuthService();
  _auth.signOut(context);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

class _HomePageState extends State<HomePage> {
  String _userName = '';
  String _userEmail = '';
  List<Event> events = [];
  int _selectedIndex = 0;

  //Nav bar
  /*static List<Widget> _widgetOptions = <Widget>[
    AddEventPage(),
    JoinedEventsPage(),
    HomePage(),
    ProfilePage(),
  ];*/

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _refreshEvents();
  }

  Future<void> _loadUserData() async {
    try {
      AuthService _auth = AuthService();
      //final userName = _auth.getCurrentUser()!.displayName;
      
      final user = _auth.getCurrentUser()!.email??'';
      print("kjvdzknlbcxkjxv$user");
     setState(() {
       // _userName = userName!;
        _userEmail = user;
      });
      print('iugefsiuds${_userEmail}');
      
     
    } catch (error) {
      print("Error loading user data: $error");
    }
  }

  void _shareText(String text) {
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
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
        backgroundColor: ScaffoldColor,
        appBar: MyAppBar(context),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 0,
          onItemTapped: (int value) {},
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*  SizedBox(height: screenSize.height * 0.02),
                Center(
                  child: MyButton2(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEventPage()),
                      );
                    },
                    text: 'Create Event',
                    color: Color(0xff90CAF9),
                    imageAsset: 'assets/icons/arrowright.png',
                  ),
                ),
                SizedBox(height: height * 0.02),
                MyButton2(
                  onTap: () {},
                  text: 'Joined Events',
                  color: Color(0xff80DEEA),
                  imageAsset: 'assets/icons/arrowright.png',
                ),
                SizedBox(height: height * 0.02),*/
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width * 0.1,
                      ),
                      Flexible(
                        child: Text(
                          'Upcoming Events',
                          style: TextStyle(
                              fontSize: screenSize.width * 0.08,
                              fontWeight: FontWeight.w500 // Adjust font size
                              ),
                          /* colors: [
                            Colors.blue,
                            Colors.red,
                            Colors.teal,
                          ],*/
                        ),
                      ),
                      IconButton(
                        // Add IconButton for refresh
                        icon: Icon(Icons.refresh),
                        onPressed: _refreshEvents,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshEvents,
                    child: FutureBuilder(
                      future: _getEventsFromFirestore(),
                      builder: (context, AsyncSnapshot<List<Event>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          List<Event> events = snapshot.data!;
                          return event_builder(
                              context, events, _userEmail, true);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            FloatingDrawer(
              userEmail: _userEmail,
              onProfileTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              /*onSettingsTap: () {
                // Implement settings navigation
              },*/
              onInviteFriendsTap: () =>
                  //TODO: Implement invite friends functionality
                  _shareText('Check out this awesome app!'),
              onSupportTap: () async {
                String email =
                    Uri.encodeComponent("studentwellbeing@gmail.com");
                String subject = Uri.encodeComponent("Need support regarding");
                String body =
                    Uri.encodeComponent("Hello Student Wellbeing team...");
                print(subject); //output: Hello%20Flutter
                Uri mail =
                    Uri.parse("mailto:$email?subject=$subject&body=$body");
                if (await launchUrl(mail)) {
                  //email app opened
                } else {
                  //email app is not opened
                }
              },
              onLogoutTap: () => logout(context),
            ),
          ],
        ),
      ),
    );
  }

/*  Future<void> _refreshEvents() async {
    setState(() {});

    List<Event> refreshedEvents = await _getEventsFromFirestore();

    setState(() {
      events = refreshedEvents;
    });
  }*/
/*  _sendEmail(String receiverName) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'recipient@example.com',
      queryParameters: {
        'subject': 'Subject',
        'body': 'Hello $receiverName,',
      },
    );
    String url = params.toString();
    if (await canLaunchUrl(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }*/

  Future<void> _refreshEvents() async {
    if (!mounted) return; // Check if the widget is still mounted

    setState(
        () {}); // You can remove this setState since it doesn't seem to serve a purpose

    List<Event> refreshedEvents = await _getEventsFromFirestore();

    if (!mounted)
      return; // Check if the widget is still mounted before updating the state
    setState(() {
      events = refreshedEvents;
    });
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  Future<List<Event>> _getEventsFromFirestore() async {
    QuerySnapshot eventSnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    List<Event> events = [];
    eventSnapshot.docs.forEach((doc) {
      events.add(Event.fromFirestore(doc));
    });
    return events;
  }
}
