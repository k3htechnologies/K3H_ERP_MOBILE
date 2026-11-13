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
  bool withBorder = true,
  double borderRadius = 20,
}) {
  final chip = Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    decoration: BoxDecoration(
      color: bg,
      border:
          withBorder
              ? Border.all(color: txtC.withValues(alpha: 0.5), width: 0.5)
              : null,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) leading,
        if (leading != null) SizedBox(width: spacing),

        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: (textStyle ?? AppTextStyle.ts10M()).copyWith(color: txtC),
          ),
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
  bool expand = false,
  Widget? leading,
  Widget? trailing,
  double spacing = 4,
  bool withBorder = true,
  double borderRadius = 20,
}) {
  final trimmed = status.trim();
  final defaultStyle = textStyle ?? AppTextStyle.ts12M();

  if (trimmed.isEmpty) {
    if (!showDashWhenEmpty) {
      return const SizedBox.shrink();
    }
    return Text("-", style: defaultStyle);
  }

  final statusConfig = config[trimmed.toLowerCase()];

  final bgColor = statusConfig?.backgroundColor ?? const Color(0x261D1D1D);

  final textColor = statusConfig?.textColor ?? const Color(0xFF333333);

  final chip = Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
    decoration: BoxDecoration(
      color: bgColor,
      border:
          withBorder
              ? Border.all(color: textColor.withValues(alpha: 0.5), width: 0.5)
              : null,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, SizedBox(width: spacing)],
        Flexible(
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: defaultStyle.copyWith(color: textColor),
          ),
        ),
        if (trailing != null) ...[SizedBox(width: spacing), trailing],
      ],
    ),
  );

  return expand ? Flexible(child: chip) : chip;
}
