import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';

import '../../groupchat/group_chat_bubble.dart';
import '../../constants.dart';
import '../../groupchat/group_chat_service.dart';

class SubGroupChatPage extends StatefulWidget {
  final String eventId;
  final String currentUserEmail;
  final String subgroupID;

  SubGroupChatPage({
    required this.eventId,
    required this.currentUserEmail,
    required this.subgroupID,
  });

  @override
  State<SubGroupChatPage> createState() => _SubGroupChatPageState();
}

class _SubGroupChatPageState extends State<SubGroupChatPage> {
  final GroupChatService _chatService = GroupChatService();
  late String _currentUserEmail;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentUserEmail = widget.currentUserEmail;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)
            .unfocus(); // Dismiss keyboard when tapping outside of text field
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(
            "Sub Group Chat",
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
            MessageInputField(
              onSendMessage: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getSubgroupChatMessages(
          widget.eventId,
          widget
              .subgroupID), // Change 'selected_subgroup_id' to the ID of the selected subgroup
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

  void _sendMessage(String message) {
    _chatService.sendMessageToSubgroupChat(
      widget.eventId,
      widget.subgroupID,
      message,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }
}

class MessageInputField extends StatefulWidget {
  final Function(String) onSendMessage;

  const MessageInputField({
    Key? key,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  _MessageInputFieldState createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      widget.onSendMessage(message);
      _messageController.clear();
    }
  }
}
