import 'package:flutter/material.dart';
// Import SvgPicture

class MyButton2 extends StatelessWidget {
  final String text;
  final String? imageAsset; // Added an imageAsset parameter for PNG or SVG
  final Color? color;
  final void Function()? onTap;

  const MyButton2({
    Key? key,
    required this.text,
    required this.color,
    required this.onTap,
    this.imageAsset, // Initialize imageAsset
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return ElevatedButton(
      onPressed: onTap,
      child: SizedBox(
        width: width * 0.8,
        height: width * 0.15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: 'ABC Diatype',
                fontWeight: FontWeight.w600,
                fontSize: width * 0.07,
              ),
            ),
            if (imageAsset != null) // Conditionally add image if provided
              Image.asset(
                imageAsset!,
                width: width * 0.09, // Adjust width as needed
                height: width * 0.09, // Adjust height as needed
              ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * 0.03),
        ),
        elevation: 5,
      ),
    );
  }
}
