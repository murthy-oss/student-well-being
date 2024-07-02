import 'package:flutter/material.dart';
import 'package:student_welbeing/utils/SizeConfig.dart';

const Color PrimaryColor = Color(0xff00B3FF);
const Color SecondaryColor = Color(0xff01AA0D);
Color? ScaffoldColor = Colors.white;

// Inside your event_builder function or wherever you're using font sizes
double fontSize = SizeConfig.screenWidth;

TextStyle kTitletextstyle = TextStyle(
  fontWeight: FontWeight.w600,
  fontFamily: 'ABC Diatype',
  fontSize: fontSize * 0.04,
);

TextStyle kdetailstext = TextStyle(
    fontWeight: FontWeight.w600,
    fontFamily: 'ABC Diatype',
    fontSize: fontSize * 0.03,
    color: Colors.black54);

TextStyle ksubTextstyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'ABC Diatype',
    color: Colors.black54);

TextStyle kDateTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  fontFamily: 'ABC Diatype',
  color: Color(0xff333333),
);

TextStyle kHeadText = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    fontFamily: 'ABC Diatype',
    color: Colors.black);

ButtonStyle keventbuttonstyle({
  required Color? backgroundColor,
  required Color foregroundColor,
  required Color shadowColor,
}) {
  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor ?? Color(0xffAED6F1),
    foregroundColor: foregroundColor,
    shadowColor: shadowColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SizeConfig.screenWidth * 0.03),
      side: BorderSide(color: Colors.black, width: 1),
    ),
    elevation: 5,
  );
}
