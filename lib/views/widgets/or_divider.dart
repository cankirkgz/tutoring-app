import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider({super.key, this.text = "Or continue with"});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            endIndent: 10, // Sağ boşluk
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 10, // Sol boşluk
          ),
        ),
      ],
    );
  }
}
