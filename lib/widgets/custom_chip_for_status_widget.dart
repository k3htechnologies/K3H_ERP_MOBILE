import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class StatusConfig {
  final Color backgroundColor;
  final Color textColor;

  const StatusConfig({required this.backgroundColor, required this.textColor});
}

// STATUS CHIP
Widget statusChip(
  String text,
  Color bg,
  Color txtC, {
  bool expand = false,
  TextStyle? textStyle,
  Widget? leading,
  Widget? trailing,
  double spacing = 4,
}) {
  final chip = Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    decoration: BoxDecoration(
      color: bg,
      border: Border.all(color: txtC.withValues(alpha: 0.5), width: 0.5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) leading,
        if (leading != null) SizedBox(width: spacing),

        Text(
          text,
          textAlign: TextAlign.center,
          style: (textStyle ?? AppTextStyle.ts10M()).copyWith(color: txtC),
        ),

        if (trailing != null) SizedBox(width: spacing),
        if (trailing != null) trailing,
      ],
    ),
  );

  return expand ? Flexible(child: chip) : chip;
}

Widget commonStatusWidget({
  required String status,
  required Map<String, StatusConfig> config,
  TextStyle? textStyle,
  bool showDashWhenEmpty = true,
  Widget? leading,
  Widget? trailing,
}) {
  final trimmed = status.trim();
  final defaultStyle = AppTextStyle.ts12M();

  if (trimmed.isEmpty) {
    if (!showDashWhenEmpty) {
      return const SizedBox.shrink();
    }

    return Text("-", style: defaultStyle);
  }

  final key = trimmed.toLowerCase();
  final statusConfig = config[key];

  if (statusConfig == null) {
    return statusChip(
      status,
      const Color(0x261D1D1D),
      const Color(0xFF333333),
      textStyle: textStyle ?? defaultStyle,
      leading: leading,
      trailing: trailing,
    );
  }

  return statusChip(
    status,
    statusConfig.backgroundColor,
    statusConfig.textColor,
    textStyle: (textStyle ?? defaultStyle).copyWith(
      color: statusConfig.textColor,
    ),
    leading: leading,
    trailing: trailing,
  );
}
