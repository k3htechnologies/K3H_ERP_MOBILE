import 'package:flutter/material.dart';
import 'package:k3h_erp_app/style/app_color.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final double? size;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? AppColor.lightBlue : Colors.transparent,
          border: Border.all(
            color: value ? AppColor.primary : AppColor.grey30,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: size! * 0.7,
                color: AppColor.primary,
              )
            : null,
      ),
    );
  }
}
