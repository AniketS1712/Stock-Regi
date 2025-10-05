import 'package:flutter/material.dart';
import 'package:stock_register/colors.dart';

class AppLogo extends StatelessWidget {
  final String appName;
  final String logoPath;
  final double logoSize;
  final TextStyle? textStyle;

  const AppLogo({
    super.key,
    this.appName = 'Stock Regi',
    this.logoPath = 'assets/images/logo.png',
    this.logoSize = 48,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w900,
      fontSize: 24,
      color: deepBrown,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          logoPath,
          height: logoSize,
          width: logoSize,
          fit: BoxFit.contain,
          semanticLabel: "$appName logo",
        ),
        const SizedBox(width: 12),
        Text(appName, style: textStyle ?? defaultStyle),
      ],
    );
  }
}
