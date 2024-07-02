import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color color;
  final void Function()? onTap;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // Adjust as needed
        height: 50,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                fontFamily: 'ABC Diatype',
                fontWeight: FontWeight.w600,
                fontSize: 30),
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 0),
    );
  }
}
