import 'package:flutter/material.dart';

class myDivider extends StatelessWidget {
  const myDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 20),
        Expanded(child: Divider()),
        SizedBox(width: 10),
        Text(
          "OR",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'ABC Diatype',
              fontSize: 16),
        ),
        SizedBox(width: 10),
        Expanded(child: Divider()),
        SizedBox(width: 20),
      ],
    );
  }
}
