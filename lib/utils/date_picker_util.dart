import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';
import 'package:intl/intl.dart';


class DatePickerUtil {
  static Future<DateTime?> pickDate({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: skyBlue,
              onPrimary: Colors.white,
              onSurface: night,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
