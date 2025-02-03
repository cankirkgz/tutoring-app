import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final double borderRadius;
  final double padding;
  final List<BoxShadow> boxShadow;

  const CustomImageWidget({
    required this.imagePath,
    required this.backgroundColor,
    this.borderRadius = 16,
    this.padding = 16,
    this.boxShadow = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        width: MediaQuery.of(context).size.width * 0.7,
      ),
    );
  }
}
