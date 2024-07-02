import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:student_welbeing/constants.dart';
import 'package:student_welbeing/models/event_model.dart';
import 'package:student_welbeing/screens/Home/home_page.dart';
import 'package:student_welbeing/screens/AddEvent/requestPage.dart';
import 'package:student_welbeing/services/authentication/auth_service.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';
import '../../components/navbar.dart';
import '../../services/data_update/event_service.dart';
import '../../utils/utils.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  Uint8List? _image;

  AuthService auth = AuthService();
  final List<String> modetype = [
    'Physical',
    'Virtual',
  ];
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  bool _isSaving = false;
  late String _hostName;
  late String _title;
  late DateTime _dateTime = DateTime.now();
  late String _location;
  late String _description;
  late String _mode;
  late List<String> _coHostNames = [];
  late TextEditingController _dateTimeController;
  late String creatorid;
//
//
  /*
  late double _ticketPrice;
*/
  //
  //
  //
  //
  //
  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController
    _dateTimeController = TextEditingController();
    getCurrentUser();
  }

  void getCurrentUser() async {
    creatorid = (await auth.getCurrentUserID())!;
  }

  @override
  void dispose() {
    // Dispose the TextEditingController
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = SizeConfig.screenWidth;
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
        bottomNavigationBar: BottomNavBar(
          selectedIndex: 1,
          onItemTapped: (int value) {},
        ),
        backgroundColor: ScaffoldColor,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width * 0.04,
              ),
              Text(
                'Add Event',
                style: kTitletextstyle.copyWith(
                    fontSize: SizeConfig.screenWidth * 0.05,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
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
                        DropdownButtonFormField2<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xffEEEEEE),
                            contentPadding: EdgeInsets.fromLTRB(0, 20, 25, 20),

                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none),
                            // Add more decoration..
                          ),
                          hint: const Text(
                            'Select Event Mode',
                            style: TextStyle(
                                fontFamily: 'ABC Diatype',
                                fontWeight: FontWeight.w600),
                          ),
                          items: modetype
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                          fontFamily: 'ABC Diatype',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select event mode.';
                            }
                            return null;
                          },
                          onChanged: (value) {},
                          onSaved: (value) {
                            _mode = value.toString();
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(right: 8),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              HeroIcons.chevron_down,
                              color: Colors.black45,
                            ),
                            iconSize: 24,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5),
                          ),
                        ),
                        SizedBox(height: width * 0.05),
                        _buildInputField(
                          labelText: 'Location',
                          // Set readOnly based on mode

                          initialValue: '',
                          onSaved: (value) => _location = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter location \nEnter location as 'Online' if event is Virtual";
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
                        /*   SizedBox(height: 20),
                        _buildInputField(
                          labelText: 'Ticket Price',
                          initialValue: '',
                          onSaved: (value) => _ticketPrice = double.parse(value!),
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
                        ),*/
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
                                horizontal: 20.0, vertical: 5),
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
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: width * 0.05),
                        GestureDetector(
                          onTap: selectImage,
                          child: Container(
                            height: width * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color(0xffEEEEEE),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
                              child: Row(
                                children: [
                                  Text(
                                    'Add Event Image',
                                    style: TextStyle(
                                        fontFamily: 'ABC Diatype',
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black54,
                                        fontSize: width * 0.04),
                                  ),
                                  Spacer(),
                                  Icon(Clarity.image_gallery_line),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: width * 0.05),
                    // Add a variable to track saving progress

                    ElevatedButton(
                      onPressed: () async {
                        if (_isSaving)
                          return; // Prevent multiple clicks while saving
                        setState(() {
                          _isSaving = true; // Set saving state to true
                        });
                        bool? isAuthorized = await auth.getIsAuthorized();
                        if (isAuthorized != 0 && isAuthorized == true) {
                          if (_formKey.currentState!.validate()) {
                            String imageUrl = await EventService()
                                .uploadImageToStorage(_image!);
                            _formKey.currentState!.save();
                            final event = Event(
                              hostName: _hostName,
                              dateTime:
                                  _dateTime, // Use the combined date and time
                              location: _location,
                              description: _description,
                              coHostNames: _coHostNames,
                              title: _title,
                              mode: _mode,
                              createdby: '',
                              creater_email: '',
                              id: '',
                              participants: [creatorid],
                              creatorid: '',
                              mainImageUrl: imageUrl,
                              imageUrls: [],
                            );
                            bool success =
                                await _eventService.addEvent(context, event);
                            _showEventCreationStatus(success);
                          }
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReqAdmin()));
                        }
                        setState(() {
                          _isSaving = false; // Set saving state back to false
                        });
                      },
                      child: Stack(
                        // Use Stack to overlay the progress indicator
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.13,
                            child: Center(
                              child: Text(
                                'Save Event',
                                style: TextStyle(
                                  fontFamily: 'ABC Diatype',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30,
                                ),
                              ),
                            ),
                          ),
                          if (_isSaving) // Show the progress indicator if saving is in progress
                            Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            labelStyle: TextStyle(
                fontFamily: 'ABC Diatype', fontWeight: FontWeight.w600),
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

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);

    setState(() {
      _image = img;
    });
  }
}
