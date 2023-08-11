
import 'package:flutter/material.dart';

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    path.lineTo(0, h-50); 

    // breeze

    path.quadraticBezierTo(w/3, h + 50, w, h - 150);
    path.lineTo(w, 0); 
    path.close(); 

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }

}