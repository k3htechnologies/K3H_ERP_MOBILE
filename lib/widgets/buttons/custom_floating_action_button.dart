import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

class CommonFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const CommonFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor = AppColor.green,
    this.iconColor = AppColor.white,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.only(bottom: 20),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }
}