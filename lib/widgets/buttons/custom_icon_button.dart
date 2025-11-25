import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? size;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor=AppColor.primary,
    this.backgroundColor=AppColor.lightBlue,
    this.size=24,
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
        padding: EdgeInsets.all(8),
        child: Icon(icon,color: iconColor,),
      ),
    );
  }
}
