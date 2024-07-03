import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// import '../profile/profilePage.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String UserName;
  final String ProfilePicture;
  final String UId;

  const ChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.UserName,
    required this.ProfilePicture,
    required this.UId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  StreamController<QuerySnapshot>? _streamController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _streamController = StreamController<QuerySnapshot>();
    _fetchTargetUserInfo(); // Fetch the target user's info
    _fetchMessages(); // Initial fetch of messages
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _streamController?.close();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Implement any logic you need when scrolling reaches the bottom
    }
  }

  void _updateRecentMessage(String message, String senderUid) {
    FirebaseFirestore.instance.collection('chatRooms').doc(widget.chatRoomId).update({
      'recentMessage': message
    });
  }

  void _fetchMessages() {
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      if (_streamController != null && !_streamController!.isClosed) {
        _streamController!.add(snapshot); 
       
        
        // Add the snapshot to the stream controller
      } else {
        _streamController = StreamController<QuerySnapshot>(); // Create a new stream controller
        _streamController!.add(snapshot); // Add the snapshot to the new stream controller
      }
     //  print('bkubhjubhjuujbbj${_streamController?.stream.length}');
    });
  }

  void _fetchTargetUserInfo() async {
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .get();

    List<String> users = List.from(roomSnapshot['users']);

    // Find the target user's UID
    // String targetUserUid = users.firstWhere((uid) => uid != FirebaseAuth.instance.currentUser!.uid);

    // DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(targetUserUid)
    //     .get();
  }

  void _sendMessage(String messageText, File? imageFile) async {
    if (messageText.isEmpty && imageFile == null) {
      return; // Return if both message text and image are empty
    }

    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await _uploadImageToFirebase(imageFile);
    }

    _updateRecentMessage(messageText.trim(), FirebaseAuth.instance.currentUser!.uid);

    FirebaseFirestore.instance.collection('chatRooms').doc(widget.chatRoomId).collection('messages').add({
      'message': messageText,
      'senderUid': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': Timestamp.now(),
      'imageUrl': imageUrl ?? 'assets/images/img_2.png',
    });

    _messageController.clear();
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      await _downloadImageToDevice(downloadUrl);
      return downloadUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<void> _downloadImageToDevice(String imageUrl) async {
    try {
      HttpClient client = HttpClient();
      var request = await client.getUrl(Uri.parse(imageUrl));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = File('$dir/image.jpg');
      await file.writeAsBytes(bytes);
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.UId),));
          },
          child: CircleAvatar(
            backgroundImage: widget.ProfilePicture.isEmpty
          ? AssetImage('assets/images/img_2.png')
          : CachedNetworkImageProvider(widget.ProfilePicture) as ImageProvider,
          ),
        ),
        title: Text(widget.UserName),
        actions: [
          IconButton(
            onPressed: () {},
            icon: FaIcon(Icons.videocam_outlined, size: 30),
          ),
          IconButton(
            onPressed: () {},
            icon: FaIcon(Icons.local_phone_outlined, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _streamController!.stream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   _scrollController.animateTo(
                //     _scrollController.position.maxScrollExtent,
                //     duration: Duration(milliseconds: 250),
                //     curve: Curves.easeInOut,
                //   );
                // });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    print({'uhuiu${data}'});
                    // Check if the message sender is the current user
                    bool isCurrentUser = (data['senderUid'] == FirebaseAuth.instance.currentUser!.uid);

                    return Row(
                      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        BubbleMessage(
                          isCurrentUser: isCurrentUser,
                          sender: isCurrentUser ? 'You' : widget.UserName,
                          targetUserName: isCurrentUser ? '' : widget.UserName,
                          text: data['message'],
                          imageUrl: 'assets/images/img_2.png',
                          timestamp: data['timestamp'],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(), // Pass context and image picker
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    final picker = ImagePicker();

    Future<void> _getImage(ImageSource source) async {
      final pickedFile = await picker.getImage(source: source);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        _sendMessage('', imageFile); // Send empty message and the selected image
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: FaIcon(Iconsax.sticker_outline),
            onPressed: () async {
              await _getImage(ImageSource.camera);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration.collapsed(hintText: 'Type your message here'),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.paperclip),
                onPressed: () async {
                  await _getImage(ImageSource.gallery);
                },
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  _sendMessage(_messageController.text.trim(), null); // Send only text message
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BubbleMessage extends StatelessWidget {
  final bool isCurrentUser;
  final String sender;
  final String targetUserName; // Add this parameter
  final String text;
  final String? imageUrl;
  final Timestamp timestamp;

  const BubbleMessage({
    Key? key,
    required this.isCurrentUser,
    required this.sender,
    required this.targetUserName, // Update constructor to accept targetUserName
    required this.text,
    this.imageUrl,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat.yMd().add_jm().format(timestamp.toDate());
    // Format timestamp as a string representing date and time

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(sender,style: TextStyle(
              color: Colors.grey.shade500
             ),),
              
            if (text.isNotEmpty)
              Text(
                text,
                // style: TextStyle(
                //   color: isCurrentUser ? Colors.white : Colors.black,
                //   fontSize: 15.sp,
                // ),
              ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              // style: TextStyle(
              //   fontWeight: FontWeight.w600,
              //   fontSize: 10.sp,
              //   color: isCurrentUser ? Colors.white : Colors.black,
              // ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
