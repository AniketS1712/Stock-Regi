import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: night),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate.toLocal().toString().split(' ')[0],
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today, size: 18, color: night),
          ],
        ),
      ),
    );
  }
}
