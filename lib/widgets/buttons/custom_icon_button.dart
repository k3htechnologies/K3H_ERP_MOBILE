import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon; // <--- changed
  final Color? backgroundColor;
  final double? size;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,     // <--- widget now
    this.backgroundColor = AppColor.lightBlue,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: size,
          width: size,
          child: icon, // <--- widget rendered here
        ),
      ),
    );
  }
}
