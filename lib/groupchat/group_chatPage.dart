import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';

import 'group_chat_bubble.dart';
import '../constants.dart';
import 'group_chat_service.dart';

class GroupChatPage extends StatefulWidget {
  final String eventId;
  final String curUserEmail;

  GroupChatPage({
    required this.eventId,
    required this.curUserEmail,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final GroupChatService _chatService = GroupChatService();
  final ScrollController _scrollController = ScrollController();
  late String _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = widget.curUserEmail;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Group Chat',
          style: kTitletextstyle.copyWith(
              fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getEventChatMessages(widget.eventId),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>?> snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        List<DocumentSnapshot> reversedDocs =
            snapshot.data!.docs.reversed.toList();
        return ListView.builder(
          reverse: false,
          controller: _scrollController,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var messageData = snapshot.data!.docs[index].data();
            Key key = UniqueKey();

            return FutureBuilder(
              key: key,
              future: _getSenderName(messageData['senderEmail']),
              builder: (context, AsyncSnapshot<String> senderSnapshot) {
                if (senderSnapshot.connectionState == ConnectionState.waiting) {
                  return Text("");
                } else if (senderSnapshot.hasError) {
                  return Text("Error");
                } else {
                  return MyChatBubble(
                    message: messageData['message'],
                    time: _formatTimestamp(messageData['timestamp']),
                    isCurrentUser:
                        _currentUserEmail == messageData['senderEmail'],
                    senderName: senderSnapshot.data ??
                        'Unknown', // Use sender name or default to 'Unknown'
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE d MMM hh:mm a').format(dateTime);
  }

  Widget _buildUserInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(20),
                hintText: 'Enter your message here!...',
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
            width: MediaQuery.of(context).size.width * 0.03,
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              size: MediaQuery.of(context).size.width * 0.09,
              color: Colors.green,
            ),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatService.sendMessageToEventChat(
        widget.eventId,
        message,
      );
      _messageController.clear();
    }
  }

  Future<String> _getSenderName(String senderEmail) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot senderSnapshot =
        await _firestore.collection("Users").doc(senderEmail).get();

    if (senderSnapshot.exists) {
      return senderSnapshot.get('name');
    } else {
      return 'Unknown';
    }
  }
}
