import 'package:flutter/material.dart';

PageRouteBuilder generatePageRouteBuilder(Widget destinationPage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => destinationPage,
    transitionDuration: Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}
