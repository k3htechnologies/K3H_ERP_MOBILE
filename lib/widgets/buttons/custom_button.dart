import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:k3h_erp_app/style/app_color.dart';
import 'package:k3h_erp_app/style/text_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final Widget? leading;
  final double elevation;
  final double height;
  final bool isDisable;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final TextStyle? titleTextStyle;
  final List<BoxShadow>? boxShadow;

  const CustomButton({
    super.key,
    required this.text,
    this.backgroundColor = AppColor.primary,
    this.textColor = AppColor.white,
    this.borderRadius = 6,
    this.padding = const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
    this.leading,
    this.elevation = 5.0,
    this.height = 44.0,
    this.isDisable = false,
    required this.onPressed,
    this.borderColor,
    this.titleTextStyle,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:isDisable? null: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.transparent,
        surfaceTintColor: AppColor.grey,
        disabledBackgroundColor: AppColor.grey30,
        side: BorderSide(color: borderColor ?? Colors.transparent),
        padding: padding,
        elevation: 0,
        fixedSize: Size.fromHeight(height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              style: titleTextStyle ?? AppTextStyle.ts12SB(color: isDisable? AppColor.black:textColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // === Named Constructors ===

  CustomButton.save({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Save',
    leading: Icon(Icons.bookmark_added, color: AppColor.white),
    backgroundColor: AppColor.green.withValues(alpha: 0.8),
    boxShadow: [
      BoxShadow(
        color: AppColor.darkGreen,
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  CustomButton.add({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Add',
    leading: Icon(Icons.add, color: AppColor.white),
    backgroundColor: AppColor.green.withValues(alpha: 0.8),
    boxShadow: [
      BoxShadow(
        color: AppColor.darkGreen,
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  CustomButton.view({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'View',
    backgroundColor: AppColor.info,
    textColor: AppColor.white,
    boxShadow: [
      BoxShadow(
        color: AppColor.black10.withValues(alpha: 0.02),
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  CustomButton.smallView({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'View',
    backgroundColor: AppColor.info,
    textColor: AppColor.white,
    borderRadius: 10.0,
    height: 30.0,
    titleTextStyle: AppTextStyle.ts14M(color: AppColor.white),
    elevation: 3.0,
    padding: EdgeInsets.symmetric(horizontal: 10.0),
    boxShadow: [
      BoxShadow(
        color: AppColor.black10.withValues(alpha: 0.02),
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        inset: true,
      ),
    ],
  );

  // ---------------- OUTLINE BUTTONS ----------------

// CANCEL (OUTLINE)
  CustomButton.cancelOutline({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Cancel',
    backgroundColor: Colors.transparent,
    textColor: AppColor.grey,
    borderColor: AppColor.grey,
    elevation: 0,
    boxShadow: [],
  );

// RESET (OUTLINE)
  CustomButton.resetOutline({Key? key, required VoidCallback onPressed})
      : this(
    key: key,
    onPressed: onPressed,
    text: 'Reset',
    backgroundColor: Colors.transparent,
    textColor: AppColor.warning,
    borderColor: AppColor.warning,
    elevation: 0,
    boxShadow: [],
  );

}