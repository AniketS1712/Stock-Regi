import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';

Widget buildCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  Color textColor = cream,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withAlpha(100),
            color.withAlpha(255),
            color.withAlpha(245),
            color.withAlpha(230),
            color.withAlpha(210),
            color.withAlpha(190),
            color.withAlpha(170),
            color.withAlpha(190),
            color.withAlpha(210),
            color.withAlpha(230),
            color.withAlpha(245),
            color.withAlpha(255),
            color.withAlpha(100),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: textColor),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
