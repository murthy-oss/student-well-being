import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_welbeing/widget_builders/generateRouteBuilder.dart';
import 'package:uuid/uuid.dart';

import '../../constants.dart';
import '../../utils/SizeConfig.dart';

// ignore: must_be_immutable
class EventGallery extends StatefulWidget {
  bool createdByUser;
  final String eventid;
  EventGallery({super.key, required this.createdByUser, required this.eventid});

  @override
  State<EventGallery> createState() => _EventGalleryState();
}

class _EventGalleryState extends State<EventGallery> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    final width = SizeConfig.screenWidth;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color here
        ),
        actions: [
          if (widget.createdByUser)
            Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: IconButton(
                icon: Icon(Icons.add_a_photo_outlined),
                onPressed: () {
                  // Call method to pick and upload images
                  pickAndUploadImages().then((imageUrls) {
                    // Update event document with image URLs
                    updateEventWithImageUrls(imageUrls);
                  });
                },
              ),
            )
        ],
        backgroundColor: Colors.blueAccent,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width * 0.04,
            ),
            Text(
              'Event Gallery',
              style: kTitletextstyle.copyWith(
                  fontSize: SizeConfig.screenWidth * 0.05, color: Colors.white),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Extract image URLs from the document data
          List<String> imageUrls =
              List<String>.from(snapshot.data!.get('imageUrls') ?? []);

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Adjust the number of columns as needed
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    generatePageRouteBuilder(
                        FullScreenImageView(imageUrl: imageUrls[index]))),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> pickAndUploadImages() async {
    List<String> imageUrls = [];

    final picker = ImagePicker();
    List<XFile>? images =
        await picker.pickMultiImage(maxWidth: 1280, maxHeight: 720);

    for (XFile image in images) {
      // Upload image to Firebase Storage
      String imageUrl = await uploadImageToFirebase(image.path);

      // Add the download URL to the list
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Future<String> uploadImageToFirebase(String imagePath) async {
    final uuid = Uuid();
    String filename = uuid.v4();
    Reference ref = _storage.ref().child(filename);

    UploadTask uploadTask = ref.putFile(File(imagePath));
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }

  void updateEventWithImageUrls(List<String> imageUrls) {
    String eventId = widget.eventid;

    FirebaseFirestore.instance.collection('events').doc(eventId).update({
      'imageUrls': FieldValue.arrayUnion(imageUrls),
    }).then((_) {
      print('Image URLs added to the event document.');
    }).catchError((error) {
      print('Failed to add image URLs: $error');
    });
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  FullScreenImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
