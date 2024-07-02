import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:student_welbeing/dm_chat/dm_chat_bubble.dart';

import '../groupchat/group_chat_bubble.dart';
import '../services/authentication/auth_service.dart';
import 'package:student_welbeing/constants.dart';

import '../utils/SizeConfig.dart';
import 'dm_chat_service.dart';

class DMChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receivername;
  DMChatPage(
      {super.key, required this.receiverEmail, required this.receivername});

  @override
  State<DMChatPage> createState() => _DMChatPageState();
}

class _DMChatPageState extends State<DMChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final DMChatService _chatService = DMChatService();
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // focus node
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 500), () => scrollDown());
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(microseconds: 500),
          () => scrollDown(),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    myFocusNode.dispose();
  }

  // Scroll Controller

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverEmail, _messageController.text);

      //clear the controller after sending the message
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          widget.receivername,
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderEmail = _authService.getCurrentUser()!.email!;
    return StreamBuilder(
      stream: _chatService.getMessage(widget.receiverEmail, senderEmail),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser =
        data['userEmail'] == _authService.getCurrentUser()!.email;

    var alignmet = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    Timestamp timestamp = data[
        'timestamp']; // Assuming 'timestamp' field is a Firestore Timestamp

    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime
    String formattedDateTime =
        DateFormat('EEE d MMM  hh:mm a').format(dateTime);
    return Container(
      alignment: alignmet,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          MyDMChatBubble(
            message: data['message'],
            isCurrentUser: isCurrentUser,
            time: formattedDateTime,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              focusNode: myFocusNode,
              controller: _messageController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(20),
                hintText: 'Enter your message here!',
                fillColor: Color(0xFFE5E5E5),
                filled: true,
                focusColor: Color(0xffd8c8ea),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              enableSuggestions: true,
              enableIMEPersonalizedLearning: true,
              enableInteractiveSelection: true,
            ),
          ),
          SizedBox(
            width: SizeConfig.screenWidth * 0.02,
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(
              EvaIcons.paper_plane_outline,
              size: SizeConfig.screenWidth * 0.09,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}
