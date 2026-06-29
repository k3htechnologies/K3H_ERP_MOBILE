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
  Color txt, {
  bool expand = false,
  TextStyle? textStyle,
}) {
  final chip = Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: textStyle ?? AppTextStyle.ts10M(color: txt),
    ),
  );

  if (expand) {
    return Flexible(child: chip);
  }

  return chip;
}

Widget commonStatusWidget({
  required String status,
  required Map<String, StatusConfig> config,
  TextStyle? textStyle,
  bool showDashWhenEmpty = true,
}) {
  final trimmed = status.trim();
  final defaultStyle = AppTextStyle.ts12M();

  if (trimmed.trim().isEmpty) {
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
    );
  }

  return statusChip(
    status,
    statusConfig.backgroundColor,
    statusConfig.textColor,
    textStyle: (textStyle ?? defaultStyle).copyWith(
      color: statusConfig.textColor,
    ),
  );
}
