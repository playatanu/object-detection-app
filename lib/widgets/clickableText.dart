import 'package:flutter/material.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final bool isActive;

  const ClickableText(
      {super.key,
      required this.text,
      required this.onTap,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.w900 : FontWeight.w400),
      ),
    );
  }
}
