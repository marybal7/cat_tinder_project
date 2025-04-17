import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateOfLike extends StatelessWidget {
  final DateTime date;

  const DateOfLike({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(date);
    final month = DateFormat('MMMM').format(date).toLowerCase();
    final year = DateFormat('y').format(date);

    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        Text(day, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        SizedBox(width: 3),
        Text(month, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        SizedBox(width: 3),
        Text(year, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
