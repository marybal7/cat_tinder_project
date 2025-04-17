import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final Size size;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(color),
        fixedSize: WidgetStateProperty.all<Size>(size),
      ),
      onPressed: onPressed,
      child: Center(child: Text(text)),
    );
  }
}
